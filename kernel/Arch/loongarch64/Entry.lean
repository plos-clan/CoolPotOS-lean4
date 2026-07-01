prelude
import Init.Prelude
import kernel.Arch.loongarch64.Cpu
import kernel.Arch.loongarch64.Trap
import kernel.Main

namespace Arch.loongarch64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 :=
  let token := Trap.init bootInfoAddr
  haltForever (Kernel.main bootInfoAddr + token - token)

end Arch.loongarch64
