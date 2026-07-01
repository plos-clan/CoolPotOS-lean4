prelude
import Init.Prelude

namespace Kernel.Utils.Memory

@[extern "mem_load64"]
opaque load64 : UInt64 -> UInt64

@[extern "mem_load8"]
opaque load8 : UInt64 -> UInt8

@[extern "mem_store64"]
opaque store64 : UInt64 -> UInt64 -> UInt64

@[extern "mem_store32"]
opaque store32 : UInt64 -> UInt32 -> UInt32

@[extern "mem_store8"]
opaque store8 : UInt64 -> UInt8 -> UInt8

end Kernel.Utils.Memory
