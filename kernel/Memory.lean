prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Support.Memory

namespace Kernel.Memory

structure HhdmPtr where
  addr : UInt64

structure MemmapPtr where
  addr : UInt64

structure MemmapEntryPtr where
  addr : UInt64

def hhdmOffset (hhdm : HhdmPtr) : UInt64 :=
  Support.Memory.load64 (hhdm.addr + (8 : UInt64))

def memmapEntryCount (memmap : MemmapPtr) : UInt64 :=
  Support.Memory.load64 (memmap.addr + (8 : UInt64))

def memmapEntries (memmap : MemmapPtr) : UInt64 :=
  Support.Memory.load64 (memmap.addr + (16 : UInt64))

def memmapEntry (memmap : MemmapPtr) (index : UInt64) : MemmapEntryPtr :=
  { addr := Support.Memory.load64 (memmapEntries memmap + index * (8 : UInt64)) }

def memmapEntryBase (entry : MemmapEntryPtr) : UInt64 :=
  Support.Memory.load64 entry.addr

def memmapEntryLength (entry : MemmapEntryPtr) : UInt64 :=
  Support.Memory.load64 (entry.addr + (8 : UInt64))

def memmapEntryType (entry : MemmapEntryPtr) : UInt64 :=
  Support.Memory.load64 (entry.addr + (16 : UInt64))

end Kernel.Memory
