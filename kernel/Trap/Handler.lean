prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Drivers.Serial
import kernel.Trap.Frame
import kernel.Utils.Format

namespace Kernel.Trap.Handler

open Kernel.Driver
open Kernel.Utils

def handle (frame : Frame) (token : UInt64) : UInt64 :=
  Serial.writeLine
    (s!"trap vector={Format.dec64 frame.vector} status={Format.hex64 frame.status} " ++
      s!"pc={Format.hex64 frame.pc} sp={Format.hex64 frame.sp} " ++
      s!"frame={Format.hex64 frame.raw}")
    token

end Kernel.Trap.Handler
