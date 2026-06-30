prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Support.Memory

namespace Kernel.Framebuffer

structure Ptr where
  addr : UInt64

structure ResponsePtr where
  addr : UInt64

def responseFramebufferCount (response : ResponsePtr) : UInt64 :=
  Support.Memory.load64 (response.addr + (8 : UInt64))

def responseFramebuffers (response : ResponsePtr) : UInt64 :=
  Support.Memory.load64 (response.addr + (16 : UInt64))

def firstFramebuffer (response : ResponsePtr) : Ptr :=
  { addr := Support.Memory.load64 (responseFramebuffers response) }

def address (fb : Ptr) : UInt64 :=
  Support.Memory.load64 fb.addr

def width (fb : Ptr) : UInt64 :=
  Support.Memory.load64 (fb.addr + (8 : UInt64))

def height (fb : Ptr) : UInt64 :=
  Support.Memory.load64 (fb.addr + (16 : UInt64))

def pitch (fb : Ptr) : UInt64 :=
  Support.Memory.load64 (fb.addr + (24 : UInt64))

end Kernel.Framebuffer

