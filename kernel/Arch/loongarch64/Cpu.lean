prelude
import Init.Prelude

namespace Arch.loongarch64

@[extern "arch_halt"]
opaque halt : UInt64 -> UInt64

partial def haltForever (token : UInt64) : UInt64 :=
  haltForever (halt token)

end Arch.loongarch64
