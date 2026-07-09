prelude
import Init.Prelude
import Init.Data.UInt.Basic

namespace Kernel.Driver.Serial.Ns16550

class RegisterIO (Arch : Type) where
  read : UInt64 -> UInt8
  write : UInt64 -> UInt8 -> UInt64 -> UInt64

private partial def waitTransmit {Arch : Type} [RegisterIO Arch] (token : UInt64) : UInt64 :=
  if RegisterIO.read (Arch := Arch) 5 &&& 0x20 == 0 then
    waitTransmit (Arch := Arch) token
  else
    token

def init {Arch : Type} [RegisterIO Arch] (token : UInt64) : UInt64 := Id.run do
  let mut token := token
  token := RegisterIO.write (Arch := Arch) 1 0x00 token
  token := RegisterIO.write (Arch := Arch) 3 0x80 token
  token := RegisterIO.write (Arch := Arch) 0 0x03 token
  token := RegisterIO.write (Arch := Arch) 1 0x00 token
  token := RegisterIO.write (Arch := Arch) 3 0x03 token
  token := RegisterIO.write (Arch := Arch) 2 0xc7 token
  token := RegisterIO.write (Arch := Arch) 4 0x0b token
  return token

def writeByte {Arch : Type} [RegisterIO Arch] (byte : UInt8) (token : UInt64) : UInt64 :=
  RegisterIO.write (Arch := Arch) 0 byte (waitTransmit (Arch := Arch) token)

end Kernel.Driver.Serial.Ns16550
