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

class Walk {Level : Type} (src target : Level) where
  translate {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> Table Arch src -> RawAddr -> RawAddr

  map {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> RawAddr -> Table Arch src -> RawAddr -> RawAddr -> UInt64 -> UInt64 -> UInt64

  unmap {Arch : Type} [PageTableFormat Arch] :
    RawAddr -> Table Arch src -> RawAddr -> UInt64 -> UInt64

instance walkLeaf {Level : Type} {level : Level} {shift leafFlags : UInt64}
    [Leaf level shift leafFlags] : Walk level level where
  translate {Arch} [PageTableFormat Arch] _ table virt :=
    let slot := table.entry virt shift
    let raw := slot.load
    if isLeaf (Arch := Arch) raw leafFlags then
      leafValue (Arch := Arch) raw virt shift
    else
      RawAddr.null

  map {Arch} [PageTableFormat Arch] _ _ table virt phys flags token :=
    let slot := table.entry virt shift
    let raw := slot.load
    if leafFlags != (0 : UInt64) && isPresent (Arch := Arch) raw && !isHuge (Arch := Arch) raw then
      token
    else
      slot.store ((leafEntry (Arch := Arch) (level := level) phys flags).raw) token

  unmap {Arch} [PageTableFormat Arch] _ table virt token :=
    let slot := table.entry virt shift
    let raw := slot.load
    if isLeaf (Arch := Arch) raw leafFlags then
      slot.store 0 token
    else
      token

instance walkStep {Level : Type} {src child target : Level} {shift : UInt64}
    [Next src child shift] [Walk child target] : Walk src target where
  translate {Arch} [PageTableFormat Arch] hhdm table virt :=
    let slot := table.entry virt shift
    let next := slot.nextTable hhdm
    if next.isNull then
      RawAddr.null
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.translate (src := child) (target := target) (Arch := Arch) hhdm childTable virt

  map {Arch} [PageTableFormat Arch] hhdm allocator table virt phys flags token :=
    let slot := table.entry virt shift
    let next := slot.ensureNextTable hhdm allocator
    if next.isNull then
      token
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.map (src := child) (target := target) (Arch := Arch)
        hhdm allocator childTable virt phys flags token

  unmap {Arch} [PageTableFormat Arch] hhdm table virt token :=
    let slot := table.entry virt shift
    let next := slot.nextTable hhdm
    if next.isNull then
      token
    else
      let childTable : Table Arch child := Table.fromAddr next
      Walk.unmap (src := child) (target := target) (Arch := Arch) hhdm childTable virt token

def translate {Level : Type} {root target : Level}
    [PageTableFormat Arch] [Root root] [Walk root target]
    (hhdm : RawAddr) (table : Table Arch root) (virt : RawAddr) : RawAddr :=
  Walk.translate (src := root) (target := target) (Arch := Arch) hhdm table virt

def mapPage {Level : Type} {root target : Level}
    [PageTableFormat Arch] [PageInvalidation Arch] [Root root] [Walk root target]
    (hhdm allocator : RawAddr) (table : Table Arch root)
    (virt phys : RawAddr) (flags token : UInt64) : UInt64 :=
  let token := Walk.map (src := root) (target := target) (Arch := Arch)
    hhdm allocator table virt phys flags token
  PageInvalidation.invalidatePage (Arch := Arch) virt.value token

def unmapPage {Level : Type} {root target : Level}
    [PageTableFormat Arch] [PageInvalidation Arch] [Root root] [Walk root target]
    (hhdm : RawAddr) (table : Table Arch root) (virt : RawAddr) (token : UInt64) : UInt64 :=
  let token := Walk.unmap (src := root) (target := target) (Arch := Arch) hhdm table virt token
  PageInvalidation.invalidatePage (Arch := Arch) virt.value token

end Kernel.Memory.Paging
