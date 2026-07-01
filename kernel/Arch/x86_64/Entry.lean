prelude
import Init.Prelude
import kernel.Arch.x86_64.Cpu
import kernel.Main

namespace Arch.x86_64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 :=
  haltForever (Kernel.main bootInfoAddr)

end Arch.x86_64
