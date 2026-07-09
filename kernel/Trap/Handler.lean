prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Drivers.Serial.Device

namespace Kernel.Trap.Handler

open Kernel.Driver

private def writeField {Arch : Type} [Serial.Device Arch]
    (name : String) (value token : UInt64) : UInt64 :=
  Serial.writeHex64 (Arch := Arch) value (Serial.writeString (Arch := Arch) name token)

def handleRaw {Arch : Type} [Serial.Device Arch]
    (vector status pc sp raw token : UInt64) : UInt64 :=
  let token := Serial.writeString (Arch := Arch) "trap" token
  let token := writeField (Arch := Arch) " vector=" vector token
  let token := writeField (Arch := Arch) " status=" status token
  let token := writeField (Arch := Arch) " pc=" pc token
  let token := writeField (Arch := Arch) " sp=" sp token
  let token := writeField (Arch := Arch) " frame=" raw token
  Serial.writeByte (Arch := Arch) 10 token

end Kernel.Trap.Handler
