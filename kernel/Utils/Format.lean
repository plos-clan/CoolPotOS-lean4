prelude
import Init.Prelude
import Init.Data.String.Defs
import Init.Data.UInt.Basic

namespace Kernel.Utils.Format

@[extern "fmt_uint"]
opaque uint : UInt64 -> UInt8 -> String

def hex (value : UInt64) : String := uint value 16
def dec (value : UInt64) : String := uint value 10

def hex64 (value : UInt64) : String := hex value
def hex32 (value : UInt32) : String := hex value.toUInt64
def hex16 (value : UInt16) : String := hex value.toUInt64
def hex8 (value : UInt8) : String := hex value.toUInt64

def dec64 (value : UInt64) : String := dec value
def dec32 (value : UInt32) : String := dec value.toUInt64
def dec16 (value : UInt16) : String := dec value.toUInt64
def dec8 (value : UInt8) : String := dec value.toUInt64

end Kernel.Utils.Format
