prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Memory.FrameAllocator
import kernel.Memory.Hhdm

namespace Kernel.Memory.Heap

open Kernel.Memory.Address

def heapPages : UInt64 := 256

@[extern "heap_init"]
opaque initRaw : UInt64 -> UInt64 -> UInt64

def init (hhdm : RawAddr) (allocator : RawAddr) : UInt64 :=
  let phys := FrameAllocator.alloc allocator heapPages
  if phys.value == (0 : UInt64) then
    (0 : UInt64)
  else
    let virt := Hhdm.RawAddr.toVirt phys hhdm
    initRaw virt.value (heapPages * FrameAllocator.pageSize)

end Kernel.Memory.Heap
