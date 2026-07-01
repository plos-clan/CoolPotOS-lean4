prelude
import Init.Prelude
import Init.Data.String.Defs
import Init.Data.UInt.Basic

namespace Kernel.Utils.Format

@[extern "fmt_hex64"]
opaque hex64 : UInt64 -> String

end Kernel.Utils.Format
