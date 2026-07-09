prelude
import Init.Prelude
import kernel.Arch.x86_64.Cpu
import kernel.Arch.x86_64.Gdt
import kernel.Arch.x86_64.Idt
import kernel.Arch.x86_64.Paging
import kernel.Arch.x86_64.Serial
import kernel.Limine.BootInfo
import kernel.Main

namespace Arch.x86_64

@[export kernel_entry]
def kernelEntry (bootInfoAddr : UInt64) : UInt64 := Id.run do
  let mut token := bootInfoAddr
  token := Gdt.init token
  token := Idt.init token
  let bootInfo : Kernel.Memory.Address.RawAddr := { value := bootInfoAddr }
  let hhdm := Kernel.Limine.BootInfo.hhdmResponse bootInfo
  token := Kernel.main (Arch := Arch) bootInfoAddr token (Paging.root hhdm token)
  haltForever token

end Arch.x86_64
