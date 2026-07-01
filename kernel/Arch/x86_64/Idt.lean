prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Trap.Handler
import kernel.Utils.Memory

namespace Arch.x86_64.Idt

open Kernel.Utils.Memory (KernelM load64)
open Kernel.Utils.Memory.KernelM (run store16 store32 store8)

def frame (vector errorCode raw : UInt64) : Kernel.Trap.Frame := {
  vector := vector
  status := errorCode
  pc := load64 raw
  sp := load64 (raw + 24)
  raw := raw
}

@[extern "idt_base"]
opaque base : UInt64 -> UInt64

@[extern "interrupt_stub"]
opaque stub : UInt64 -> UInt64 -> UInt64

@[extern "load_idt"]
opaque loadIdt : UInt64 -> UInt64 -> UInt64

@[inline] def storeEntry
    (base vector handler : UInt64)
    (ist flags : UInt8) : KernelM Unit := do
  let entry := base + vector * 16
  store16 entry handler.toUInt16
  store16 (entry + 2) 0x08
  store8 (entry + 4) (ist &&& 0x7)
  store8 (entry + 5) flags
  store16 (entry + 6) (handler >>> 16).toUInt16
  store32 (entry + 8) (handler >>> 32).toUInt32
  store32 (entry + 12) 0

partial def registerEntries (base vector token : UInt64) : UInt64 :=
  if vector == 256 then
    token
  else
    let ist := if vector == 8 then 1 else 0
    let token := run (storeEntry base vector (stub vector token) ist 0x8e) token
    registerEntries base (vector + 1) token

def init : UInt64 -> UInt64 := run do
  let token <- get
  let idt := base token
  modify (registerEntries idt 0)
  modify (loadIdt idt)

@[export interrupt_common]
def interruptCommon (vector errorCode frame : UInt64) : UInt64 :=
  Kernel.Trap.Handler.handle (Idt.frame vector errorCode frame) frame

end Arch.x86_64.Idt
