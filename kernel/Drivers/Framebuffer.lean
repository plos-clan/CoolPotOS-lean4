prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Utils.Memory

namespace Kernel.Driver.Framebuffer

open Kernel.Memory.Address
open Kernel.Utils.Memory

def responseFramebufferCount (response : RawAddr) : UInt64 :=
  load64 (response.value + (8 : UInt64))

def responseFramebuffers (response : RawAddr) : RawAddr :=
  { value := load64 (response.value + (16 : UInt64)) }

def firstFramebuffer (response : RawAddr) : RawAddr :=
  { value := load64 (responseFramebuffers response).value }

def address (fb : RawAddr) : RawAddr :=
  { value := load64 fb.value }

def width (fb : RawAddr) : UInt64 :=
  load64 (fb.value + (8 : UInt64))

def height (fb : RawAddr) : UInt64 :=
  load64 (fb.value + (16 : UInt64))

def pitch (fb : RawAddr) : UInt64 :=
  load64 (fb.value + (24 : UInt64))

end Kernel.Driver.Framebuffer
