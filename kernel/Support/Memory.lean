prelude
import Init.Prelude

namespace Support.Memory

@[extern "mem_load64"]
opaque load64 : UInt64 -> UInt64

@[extern "mem_store32"]
opaque store32 : UInt64 -> UInt32 -> UInt32

end Support.Memory
