prelude
import Init.Prelude
import kernel.Arch.loongarch64.Cpu
import kernel.Core

namespace Arch.loongarch64

@[export lean_kernel_start]
def start (bootInfoAddr : UInt64) : UInt64 :=
  haltForever (Kernel.startCore bootInfoAddr)

end Arch.loongarch64
