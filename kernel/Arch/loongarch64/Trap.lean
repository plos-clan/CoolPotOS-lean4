prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Arch.loongarch64.Serial
import kernel.Trap.Handler
import kernel.Utils.Memory

namespace Arch.loongarch64.Trap

open Kernel.Utils.Memory

@[extern "load_trap"]
opaque loadTrap : UInt64 -> UInt64

def init (token : UInt64) : UInt64 := loadTrap token

@[export interrupt_common]
def interruptCommon (_vector status frame : UInt64) : UInt64 :=
  Kernel.Trap.Handler.handleRaw
    (Arch := Arch.loongarch64.Arch)
    (load64 (frame + 240)) status (load64 (frame + 248)) (frame + 272) frame frame

end Arch.loongarch64.Trap
