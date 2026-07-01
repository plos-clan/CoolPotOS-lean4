prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Utils.Memory

namespace Kernel.Memory.Memmap

open Kernel.Memory.Address
open Kernel.Utils.Memory

def memmapEntryCount (memmap : RawAddr) : UInt64 :=
  load64 (memmap.value + 8)

def memmapEntries (memmap : RawAddr) : RawAddr :=
  { value := load64 (memmap.value + 16) }

def memmapEntry (memmap : RawAddr) (index : UInt64) : RawAddr :=
  { value := load64 ((memmapEntries memmap).value + index * 8) }

def memmapEntryBase (entry : RawAddr) : UInt64 :=
  load64 entry.value

def memmapEntryLength (entry : RawAddr) : UInt64 :=
  load64 (entry.value + 8)

def memmapEntryType (entry : RawAddr) : UInt64 :=
  load64 (entry.value + 16)

end Kernel.Memory.Memmap
