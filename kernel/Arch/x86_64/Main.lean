prelude
import Init.Prelude
import kernel.Arch.x86_64.Cpu
import kernel.Core

namespace Arch.x86_64

@[export lean_kernel_start]
def start (bootInfoAddr : UInt64) : UInt64 :=
  haltForever (Kernel.startCore bootInfoAddr)

end Arch.x86_64
