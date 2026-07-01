prelude
import Init.Prelude
import Init.Data.UInt.Basic
import Init.Control.State

namespace Kernel.Utils.Memory

@[extern "mem_load64"]
opaque load64 : UInt64 -> UInt64

@[extern "mem_load8"]
opaque load8 : UInt64 -> UInt8

@[extern "mem_store64"]
opaque store64Ext : UInt64 -> UInt64 -> UInt64

@[extern "mem_store32"]
opaque store32Ext : UInt64 -> UInt32 -> UInt32

@[extern "mem_store16"]
opaque store16Ext : UInt64 -> UInt16 -> UInt16

@[extern "mem_store8"]
opaque store8Ext : UInt64 -> UInt8 -> UInt8

abbrev KernelM := StateM UInt64

namespace KernelM

@[inline] def run (body : KernelM Unit) (token : UInt64) : UInt64 :=
  let ((), newToken) := body token
  newToken

@[inline] def store64 (addr value : UInt64) : KernelM Unit :=
  modify fun token =>
    let written := Kernel.Utils.Memory.store64Ext addr value
    written + token - written

@[inline] def store32 (addr : UInt64) (value : UInt32) : KernelM Unit :=
  modify fun token =>
    let written := (Kernel.Utils.Memory.store32Ext addr value).toUInt64
    written + token - written

@[inline] def store16 (addr : UInt64) (value : UInt16) : KernelM Unit :=
  modify fun token =>
    let written := (Kernel.Utils.Memory.store16Ext addr value).toUInt64
    written + token - written

@[inline] def store8 (addr : UInt64) (value : UInt8) : KernelM Unit :=
  modify fun token =>
    let written := (Kernel.Utils.Memory.store8Ext addr value).toUInt64
    written + token - written

end KernelM

end Kernel.Utils.Memory
