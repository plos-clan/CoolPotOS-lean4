prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Memory.Paging.Early

namespace Kernel.Memory.Heap

open Kernel.Memory.Address
open Kernel.Memory.Paging

def heapStart : RawAddr := { value := 0xffffc00000000000 }
def heapSize : UInt64 := 8 * 1024 * 1024

@[extern "heap_init"]
opaque initRaw : UInt64 -> UInt64 -> UInt64

def init {Level : Type} {root native : Level} {shift : UInt64}
    [PageTableFormat Arch] [PageInvalidation Arch] [Root root native shift] [Walk root native shift]
    (hhdm allocator : RawAddr) (table : Table Arch root) (token : UInt64) : UInt64 :=
  let heap := Early.allocRange table hhdm allocator
    heapStart heapSize (PageTableFormat.kernelDataFlags (Arch := Arch)) token
  if heap.isNull then
    0
  else
    initRaw heap.value heapSize

end Kernel.Memory.Heap
