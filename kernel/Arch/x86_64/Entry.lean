prelude
import Init.Prelude
import kernel.Arch.x86_64.Cpu
import kernel.Arch.x86_64.Gdt
import kernel.Arch.x86_64.Idt
import kernel.Main

namespace Arch.x86_64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 :=
  let token := Gdt.init bootInfoAddr
  let token := Idt.init token
  let token := Kernel.main bootInfoAddr + token - token
  haltForever token

end Arch.x86_64
