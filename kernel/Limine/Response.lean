prelude
import Init.Prelude
import kernel.Limine.Common

namespace Limine

structure HhdmResponse where
  revision : UInt64
  offset : UInt64

structure FramebufferResponse where
  revision : UInt64
  framebuffer_count : UInt64
  framebuffers : UInt64

structure MpResponse where
  revision : UInt64
  flags : UInt64
  bsp_phys_id : UInt64
  cpu_count : UInt64
  cpus : UInt64

structure MemmapResponse where
  revision : UInt64
  entry_count : UInt64
  entries : UInt64

structure RsdpResponse where
  revision : UInt64
  address : UInt64

end Limine
