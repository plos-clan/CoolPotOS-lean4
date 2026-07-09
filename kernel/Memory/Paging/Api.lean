prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Paging.Walk

namespace Kernel.Memory.Paging

open Kernel.Memory.Address

namespace Table

variable {Level Arch : Type} {root native : Level} {shift : UInt64}
variable [PageTableFormat Arch] [PageInvalidation Arch]
variable [Root root native shift] [Walk root native shift]

def translate (table : Table Arch root) (hhdm virt : RawAddr) : Option RawAddr :=
  Walk.translate (src := root) (target := native) (targetShift := shift) (Arch := Arch)
    hhdm table virt

def mapPage
    (table : Table Arch root) (hhdm allocator virt phys : RawAddr)
    (flags token : UInt64) : Option UInt64 :=
  let ok :=
    Walk.map (src := root) (target := native) (targetShift := shift) (Arch := Arch)
      hhdm allocator table virt phys flags token
  if ok == 0 then none
  else some (PageInvalidation.invalidatePage (Arch := Arch) virt.value ok)

def unmapPage
    (table : Table Arch root) (hhdm virt : RawAddr) (token : UInt64) : Option UInt64 :=
  let ok :=
    Walk.unmap (src := root) (target := native) (targetShift := shift) (Arch := Arch)
      hhdm table virt token
  if ok == 0 then none
  else some (PageInvalidation.invalidatePage (Arch := Arch) virt.value ok)

private partial def mapFrom {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm allocator virt phys : RawAddr)
    (rem bytes flags token : UInt64) : Option UInt64 :=
  if rem == 0 then
    some token
  else
    match table.mapPage (native := native) (shift := shift)
        hhdm allocator virt phys flags token with
    | none => none
    | some token =>
      let rem := if rem <= bytes then 0 else rem - bytes
      mapFrom (native := native) (shift := shift) table hhdm allocator
        { value := virt.value + bytes } { value := phys.value + bytes }
        rem bytes flags token

def mapRange
    (table : Table Arch root) (hhdm allocator virt phys : RawAddr)
    (bytes flags token : UInt64) : Option UInt64 :=
  mapFrom (native := native) (shift := shift)
    table hhdm allocator virt phys bytes ((1 : UInt64) <<< shift) flags token

private partial def unmapFrom {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm virt : RawAddr)
    (rem bytes token : UInt64) : Option UInt64 :=
  if rem == 0 then
    some token
  else
    match table.unmapPage (native := native) (shift := shift) hhdm virt token with
    | none => none
    | some token =>
      let rem := if rem <= bytes then 0 else rem - bytes
      unmapFrom (native := native) (shift := shift)
        table hhdm { value := virt.value + bytes } rem bytes token

def unmapRange
    (table : Table Arch root) (hhdm virt : RawAddr)
    (bytes token : UInt64) : Option UInt64 :=
  unmapFrom (native := native) (shift := shift)
    table hhdm virt bytes ((1 : UInt64) <<< shift) token

private partial def allocFrom {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm allocator base virt : RawAddr)
    (rem bytes frames flags token : UInt64) : Option (RawAddr × UInt64) :=
  if rem == 0 then
    some (base, token)
  else
    let phys := FrameAllocator.alloc allocator frames
    if phys.isNull then
      none
    else
      match table.mapPage (native := native) (shift := shift)
          hhdm allocator virt phys flags token with
      | none => none
      | some token =>
        let rem := if rem <= bytes then 0 else rem - bytes
        allocFrom (native := native) (shift := shift)
          table hhdm allocator base { value := virt.value + bytes }
          rem bytes frames flags token

def allocRange
    (table : Table Arch root) (hhdm allocator virt : RawAddr)
    (bytes flags token : UInt64) : Option (RawAddr × UInt64) :=
  let unitBytes := (1 : UInt64) <<< shift
  let frames := FrameAllocator.divCeil unitBytes FrameAllocator.pageSize
  allocFrom (native := native) (shift := shift)
    table hhdm allocator virt virt bytes unitBytes frames flags token

end Table

end Kernel.Memory.Paging
