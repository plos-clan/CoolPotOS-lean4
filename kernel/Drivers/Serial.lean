prelude
import Init.Prelude
import Init.Data.String.Defs
import Init.Data.UInt.Basic
import Init.Data.ToString.Basic

namespace Kernel.Driver.Serial

@[extern "serial_init"]
opaque init : UInt64 -> UInt64

@[extern "serial_write_byte"]
opaque writeByte : UInt8 -> UInt64 -> UInt64

@[extern "serial_write_string"]
opaque writeString : String -> UInt64 -> UInt64

def writeNewline (token : UInt64) : UInt64 :=
  writeByte (10 : UInt8) token

def writeLine (text : String) (token : UInt64) : UInt64 :=
  writeNewline (writeString text token)

def writeStarted (token : UInt64) : UInt64 :=
  writeLine "CoolPotOS Lean4" token

end Kernel.Driver.Serial
