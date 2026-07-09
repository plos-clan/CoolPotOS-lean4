prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Memory.FrameAllocator
import kernel.Memory.Hhdm
import kernel.Memory.Paging.Types
import kernel.Utils.Bitmap

namespace Kernel.Memory.Paging

open Kernel.Memory.Address

namespace Table

def fromAddr (addr : RawAddr) : Table Arch level :=
  { addr := addr }

def entry [PageTableFormat Arch]
    (table : Table Arch level) (virt : RawAddr) (shift : UInt64) : EntrySlot Arch level :=
  let index := (virt.value >>> shift) &&& PageTableFormat.indexMask (Arch := Arch)
  { addr := { value := table.addr.value + (index <<< 3) } }

end Table

namespace EntrySlot

def nextTable [PageTableFormat Arch] [Next parent child indexShift]
    (slot : EntrySlot Arch parent) (hhdm : RawAddr) : RawAddr :=
  let raw := slot.load
  if isPresent (Arch := Arch) raw && !isHuge (Arch := Arch) raw then
    Hhdm.RawAddr.toVirt { value := entryAddr (Arch := Arch) raw } hhdm
  else
    RawAddr.null

def ensureNextTable [PageTableFormat Arch] [Next parent child indexShift]
    (slot : EntrySlot Arch parent) (hhdm allocator : RawAddr) : RawAddr :=
  let raw := slot.load
  if isPresent (Arch := Arch) raw && !isHuge (Arch := Arch) raw then
    Hhdm.RawAddr.toVirt { value := entryAddr (Arch := Arch) raw } hhdm
  else if isPresent (Arch := Arch) raw then
    RawAddr.null
  else
    let bytes := PageTableFormat.tableBytes (Arch := Arch)
    let frames :=
      if bytes == FrameAllocator.pageSize then 1
      else FrameAllocator.divCeil bytes FrameAllocator.pageSize
    let phys := FrameAllocator.alloc allocator frames
    if phys.isNull then
      RawAddr.null
    else
      let table := Hhdm.RawAddr.toVirt phys hhdm
      let token := Utils.Bitmap.clearBytes table.value bytes 0 phys.value
      let entry := tableEntry (Arch := Arch) phys
      let token := slot.store entry token
      { value := table.value + token - token }

end EntrySlot

end Kernel.Memory.Paging
