prelude
import Init.Prelude
import Init.Data.UInt.Basic

namespace Arch.x86_64.Port

@[extern "port_in8"]
opaque in8 : UInt16 -> UInt8

@[extern "port_out8"]
opaque out8Ext : UInt16 -> UInt8 -> UInt8

def out8 (port : UInt16) (value : UInt8) (token : UInt64) : UInt64 :=
  let written := (out8Ext port value).toUInt64
  written + token - written

end Arch.x86_64.Port
