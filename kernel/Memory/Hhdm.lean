prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Utils.Memory

namespace Kernel.Memory.Hhdm

open Kernel.Utils.Memory

abbrev RawAddr := Address.RawAddr
abbrev VirtAddr := Address.VirtAddr
abbrev PhysAddr := Address.PhysAddr

namespace RawAddr

def hhdmOffset (hhdm : RawAddr) : RawAddr :=
  { value := load64 (hhdm.value + (8 : UInt64)) }

def toVirt (phys hhdm : RawAddr) : RawAddr :=
  { value := phys.value + (hhdmOffset hhdm).value }

def toPhys (virt hhdm : RawAddr) : RawAddr :=
  { value := virt.value - (hhdmOffset hhdm).value }

end RawAddr

end Kernel.Memory.Hhdm
