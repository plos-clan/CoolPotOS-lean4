prelude
import Init.Prelude
import Init.Data.String.Defs
import Init.Data.UInt.Basic

namespace Kernel.Driver.Serial

class Device (Arch : Type) where
  init : UInt64 -> UInt64
  writeByte : UInt8 -> UInt64 -> UInt64

def writeByte {Arch : Type} [Device Arch] (byte : UInt8) (token : UInt64) : UInt64 :=
  Device.writeByte (Arch := Arch) byte token

@[extern "serial_string_size"]
private opaque stringSize : String -> UInt64

@[extern "serial_string_byte"]
private opaque stringByte : String -> UInt64 -> UInt8

private partial def writeFrom {Arch : Type} [Device Arch]
    (text : String) (index size token : UInt64) : UInt64 :=
  if index == size then
    token
  else
    let token := writeByte (Arch := Arch) (stringByte text index) token
    writeFrom (Arch := Arch) text (index + 1) size token

def writeString {Arch : Type} [Device Arch] (text : String) (token : UInt64) : UInt64 :=
  writeFrom (Arch := Arch) text 0 (stringSize text) token

def writeLine {Arch : Type} [Device Arch] (text : String) (token : UInt64) : UInt64 :=
  writeByte (Arch := Arch) 10 (writeString (Arch := Arch) text token)

private def hexDigit (value : UInt64) : UInt8 :=
  let digit := (value &&& 0xf).toUInt8
  if digit < 10 then digit + 48 else digit + 87

private partial def writeHexDigits {Arch : Type} [Device Arch]
    (value shift token : UInt64) : UInt64 :=
  if shift == 0 then
    writeByte (Arch := Arch) (hexDigit value) token
  else
    let token := writeByte (Arch := Arch) (hexDigit (value >>> shift)) token
    writeHexDigits (Arch := Arch) value (shift - 4) token

def writeHex64 {Arch : Type} [Device Arch] (value token : UInt64) : UInt64 :=
  writeHexDigits (Arch := Arch) value 60 (writeString (Arch := Arch) "0x" token)

end Kernel.Driver.Serial
