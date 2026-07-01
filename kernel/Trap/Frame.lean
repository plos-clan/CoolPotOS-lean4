prelude
import Init.Prelude
import Init.Data.UInt.Basic

namespace Kernel.Trap

structure Frame where
  vector : UInt64
  status : UInt64
  pc : UInt64
  sp : UInt64
  raw : UInt64

end Kernel.Trap
