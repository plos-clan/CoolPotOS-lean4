prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Utils.Memory

namespace Kernel.Limine.BootInfo

open Kernel.Memory.Address

def framebufferResponse (bootInfo : RawAddr) : RawAddr :=
  { value := Utils.Memory.load64 bootInfo.value }

def hhdmResponse (bootInfo : RawAddr) : RawAddr :=
  { value := Utils.Memory.load64 (bootInfo.value + (8 : UInt64)) }

def memmapResponse (bootInfo : RawAddr) : RawAddr :=
  { value := Utils.Memory.load64 (bootInfo.value + (16 : UInt64)) }

end Kernel.Limine.BootInfo
