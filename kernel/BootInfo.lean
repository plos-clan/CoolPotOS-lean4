prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Support.Memory

namespace Kernel.BootInfo

structure Ptr where
  addr : UInt64

def framebufferResponse (bootInfo : Ptr) : UInt64 :=
  Support.Memory.load64 bootInfo.addr

end Kernel.BootInfo

