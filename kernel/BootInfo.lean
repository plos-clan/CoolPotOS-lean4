prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Support.Memory

namespace Kernel.BootInfo

structure Ptr where
  addr : UInt64

def framebufferResponse (bootInfo : Ptr) : UInt64 :=
  Support.Memory.load64 bootInfo.addr

def hhdmResponse (bootInfo : Ptr) : UInt64 :=
  Support.Memory.load64 (bootInfo.addr + (8 : UInt64))

def memmapResponse (bootInfo : Ptr) : UInt64 :=
  Support.Memory.load64 (bootInfo.addr + (16 : UInt64))

end Kernel.BootInfo
