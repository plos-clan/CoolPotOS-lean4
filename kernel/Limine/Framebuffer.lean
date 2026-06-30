prelude
import Init.Prelude

namespace Limine

structure VideoMode where
  pitch : UInt64
  width : UInt64
  height : UInt64
  bpp : UInt16
  memory_model : UInt8
  red_mask_size : UInt8
  red_mask_shift : UInt8
  green_mask_size : UInt8
  green_mask_shift : UInt8
  blue_mask_size : UInt8
  blue_mask_shift : UInt8

structure Framebuffer where
  address : UInt64
  width : UInt64
  height : UInt64
  pitch : UInt64
  bpp : UInt16
  memory_model : UInt8
  red_mask_size : UInt8
  red_mask_shift : UInt8
  green_mask_size : UInt8
  green_mask_shift : UInt8
  blue_mask_size : UInt8
  blue_mask_shift : UInt8
  edid_size : UInt64
  edid : UInt64
  mode_count : UInt64
  modes : UInt64

structure FramebufferResponse where
  revision : UInt64
  framebuffer_count : UInt64
  framebuffers : UInt64

end Limine
