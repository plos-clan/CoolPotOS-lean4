prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Paging.Table

namespace Kernel.Memory.Paging

open Kernel.Memory.Address

@[inline] private def pageOffsetMask (shift : UInt64) : UInt64 :=
  ((1 : UInt64) <<< shift) - 1

@[inline] private def pageBaseMask (shift : UInt64) : UInt64 :=
  ~~~pageOffsetMask shift

@[inline] private def leafValue [PageTableFormat Arch]
    (raw : UInt64) (virt : RawAddr) (shift : UInt64) : RawAddr := {
  value :=
    (entryAddr (Arch := Arch) raw &&& pageBaseMask shift) |||
      (virt.value &&& pageOffsetMask shift)
}

@[inline] private def isLeaf [PageTableFormat Arch] (raw leafFlags : UInt64) : Bool :=
  isPresent (Arch := Arch) raw &&
    (leafFlags == (0 : UInt64) || raw &&& leafFlags == leafFlags)

class Walk {Level : Type} (src target : Level) (targetShift : UInt64) where
  translate {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> Table Arch src -> RawAddr -> Option RawAddr

  map {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> RawAddr -> Table Arch src -> RawAddr -> RawAddr -> UInt64 -> UInt64 -> UInt64

  unmap {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> Table Arch src -> RawAddr -> UInt64 -> UInt64

instance walkLeaf {Level : Type} {level : Level} {shift leafFlags : UInt64}
    [Leaf shift level leafFlags] : Walk level level shift where
  translate {Arch} [PageTableFormat Arch] _ table virt :=
    let slot := table.entry virt shift
    let raw := slot.load
    if isLeaf (Arch := Arch) raw leafFlags then
      some (leafValue (Arch := Arch) raw virt shift)
    else
      none

  map {Arch} [PageTableFormat Arch] _ _ table virt phys flags token :=
    let slot := table.entry virt shift
    let raw := slot.load
    if leafFlags != (0 : UInt64) && isPresent (Arch := Arch) raw && !isHuge (Arch := Arch) raw then
      0
    else
      let token := slot.store
        (leafEntry (pageShift := shift) (level := level) phys flags)
        token
      1 + token - token

  unmap {Arch} [PageTableFormat Arch] _ table virt token :=
    let slot := table.entry virt shift
    let raw := slot.load
    if isLeaf (Arch := Arch) raw leafFlags then
      let token := slot.store 0 token
      1 + token - token
    else
      0

instance walkStep {Level : Type} {src child target : Level} {shift : UInt64}
    {targetShift : UInt64}
    [Next src child shift] [Walk child target targetShift] : Walk src target targetShift where
  translate {Arch} [PageTableFormat Arch] hhdm table virt :=
    let slot := table.entry virt shift
    let next := slot.nextTable hhdm
    if next.isNull then
      none
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.translate
        (src := child) (target := target) (targetShift := targetShift) (Arch := Arch)
        hhdm childTable virt

  map {Arch} [PageTableFormat Arch] hhdm allocator table virt phys flags token :=
    let slot := table.entry virt shift
    let next := slot.ensureNextTable hhdm allocator
    if next.isNull then
      0
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.map
        (src := child) (target := target) (targetShift := targetShift) (Arch := Arch)
        hhdm allocator childTable virt phys flags token

  unmap {Arch} [PageTableFormat Arch] hhdm table virt token :=
    let slot := table.entry virt shift
    let next := slot.nextTable hhdm
    if next.isNull then
      0
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.unmap
        (src := child) (target := target) (targetShift := targetShift) (Arch := Arch)
        hhdm childTable virt token

end Kernel.Memory.Paging
