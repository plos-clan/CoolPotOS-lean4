prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Paging.Walk

namespace Kernel.Memory.Paging.Early

open Kernel.Memory.Address

private def mapPage {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm allocator virt phys : RawAddr)
    (flags token : UInt64) : UInt64 :=
  let ok :=
    Walk.map (src := root) (target := native) (targetShift := shift) (Arch := Arch)
      hhdm allocator table virt phys flags token
  if ok == 0 then 0
  else
    let token := PageInvalidation.invalidatePage (Arch := Arch) virt.value ok
    ok + token - token

private partial def allocFrom {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm allocator base virt : RawAddr)
    (rem bytes frames flags token : UInt64) : RawAddr :=
  if rem == 0 then
    { value := base.value + token - token }
  else
    let phys := FrameAllocator.alloc allocator frames
    if phys.isNull then
      RawAddr.null
    else
      let ok := mapPage (native := native) (shift := shift)
        table hhdm allocator virt phys flags token
      if ok == 0 then
        RawAddr.null
      else
        let rem := if rem <= bytes then 0 else rem - bytes
        allocFrom (native := native) (shift := shift)
          table hhdm allocator base { value := virt.value + bytes }
          rem bytes frames flags ok

def allocRange {Level Arch : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch]
    [Root root native shift] [Walk root native shift]
    (table : Table Arch root) (hhdm allocator virt : RawAddr)
    (bytes flags token : UInt64) : RawAddr :=
  let unitBytes := (1 : UInt64) <<< shift
  let frames := FrameAllocator.divCeil unitBytes FrameAllocator.pageSize
  allocFrom (native := native) (shift := shift)
    table hhdm allocator virt virt bytes unitBytes frames flags token

end Kernel.Memory.Paging.Early
