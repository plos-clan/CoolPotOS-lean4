prelude
import Init.Prelude
import kernel.Arch.loongarch64.Cpu
import kernel.Arch.loongarch64.Serial
import kernel.Arch.loongarch64.Trap
import kernel.Main

namespace Arch.loongarch64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 := Id.run do
  let mut token := bootInfoAddr
  token := Trap.init token
  token := Kernel.mainNoHeap (Arch := Arch) bootInfoAddr token
  haltForever token

end Arch.loongarch64
