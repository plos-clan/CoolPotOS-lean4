prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Trap.Handler
import kernel.Utils.Memory

namespace Arch.loongarch64.Trap

open Kernel.Utils.Memory

@[extern "load_trap"]
opaque loadTrap : UInt64 -> UInt64

def init (token : UInt64) : UInt64 := loadTrap token

def frame (raw status : UInt64) : Kernel.Trap.Frame := {
  vector := load64 (raw + 240)
  status := status
  pc := load64 (raw + 248)
  sp := raw + 272
  raw := raw
}

@[export interrupt_common]
def interruptCommon (_vector status frame : UInt64) : UInt64 :=
  Kernel.Trap.Handler.handle (Trap.frame frame status) frame

end Arch.loongarch64.Trap
