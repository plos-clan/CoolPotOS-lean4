prelude
import Init.Prelude
import Init.Data.UInt.Basic

namespace Arch.loongarch64.Io

@[extern "mmio_load8"]
opaque mmioLoad8 : UInt64 -> UInt8

@[extern "mmio_store8"]
opaque mmioStore8Ext : UInt64 -> UInt8 -> UInt8

def mmioStore8 (addr : UInt64) (value : UInt8) (token : UInt64) : UInt64 :=
  let written := (mmioStore8Ext addr value).toUInt64
  written + token - written

end Arch.loongarch64.Io
