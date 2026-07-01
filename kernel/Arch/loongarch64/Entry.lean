prelude
import Init.Prelude
import kernel.Arch.loongarch64.Cpu
import kernel.Main

namespace Arch.loongarch64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 :=
  haltForever (Kernel.main bootInfoAddr)

end Arch.loongarch64
