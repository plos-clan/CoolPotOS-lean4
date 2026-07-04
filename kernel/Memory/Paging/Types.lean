prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Utils.Memory

namespace Kernel.Memory.Paging

open Kernel.Memory.Address
open Kernel.Utils.Memory
open Kernel.Utils.Memory.KernelM (run store64)

inductive EntryState where
  | unmapped | table | leaf

class Root {Level : Type} (level : Level) : Prop where

class Next {Level : Type}
    (parent : Level) (child : outParam Level) (indexShift : outParam UInt64) : Prop where

class Leaf {Level : Type} (level : Level) (pageShift leafFlags : outParam UInt64) : Prop where

class PageTableFormat (Arch : Type) where
  indexMask : UInt64
  addrMask : UInt64
  present : UInt64
  huge : UInt64
  parentFlags : UInt64

class PageInvalidation (Arch : Type) where
  invalidatePage : UInt64 -> UInt64 -> UInt64

structure Table (Arch : Type) {Level : Type} (level : Level) where
  addr : RawAddr

structure Entry (Arch : Type) {Level : Type} (level : Level) (state : EntryState) where
  value : UInt64

structure EntrySlot (Arch : Type) {Level : Type} (level : Level) where
  addr : RawAddr

namespace Entry

def raw (entry : Entry arch level state) : UInt64 := entry.value

end Entry

namespace EntrySlot

def load (slot : EntrySlot arch level) : UInt64 :=
  load64 slot.addr.value

def store (slot : EntrySlot arch level) (value token : UInt64) : UInt64 :=
  run (store64 slot.addr.value value) token

end EntrySlot

def entryAddr [PageTableFormat Arch] (value : UInt64) : UInt64 :=
  value &&& PageTableFormat.addrMask (Arch := Arch)

def isPresent [PageTableFormat Arch] (value : UInt64) : Bool :=
  value &&& PageTableFormat.present (Arch := Arch) != 0

def isHuge [PageTableFormat Arch] (value : UInt64) : Bool :=
  value &&& PageTableFormat.huge (Arch := Arch) != 0

def tableEntry [PageTableFormat Arch] [Next parent child indexShift]
    (phys : RawAddr) : Entry Arch parent .table :=
  { value := phys.value ||| PageTableFormat.parentFlags (Arch := Arch) }

def leafEntry [Leaf level pageShift leafFlags]
    (phys : RawAddr) (flags : UInt64) : Entry Arch level .leaf :=
  { value := phys.value ||| flags ||| leafFlags }

end Kernel.Memory.Paging
