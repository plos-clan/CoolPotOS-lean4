prelude
import Init.Prelude
import kernel.Arch.x86_64.Cpu
import kernel.Arch.x86_64.Gdt
import kernel.Arch.x86_64.Idt
import kernel.Main

namespace Arch.x86_64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 := Id.run do
  let mut token := bootInfoAddr
  token := Gdt.init token
  token := Idt.init token
  token := Kernel.main bootInfoAddr token
  haltForever token

end Arch.x86_64
