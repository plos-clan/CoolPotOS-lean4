prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.BootInfo
import kernel.Framebuffer
import kernel.Support.Memory

namespace Kernel

def pixelColor (x y : UInt64) : UInt32 :=
  ((x.toUInt32 &&& (255 : UInt32)) <<< (16 : UInt32)) |||
  ((y.toUInt32 &&& (255 : UInt32)) <<< (8 : UInt32))

partial def drawRow
    (base width pitch y x token : UInt64) : UInt64 :=
  if x == width then
    token
  else
    let addr := base + y * pitch + x * (4 : UInt64)
    let nextToken := (Support.Memory.store32 addr (pixelColor x y)).toUInt64
    drawRow base width pitch y (x + (1 : UInt64)) nextToken

partial def draw
    (base width height pitch y token : UInt64) : UInt64 :=
  if y == height then
    token
  else
    let rowToken := drawRow base width pitch y (0 : UInt64) token
    draw base width height pitch (y + (1 : UInt64)) rowToken

def startCore (bootInfoAddr : UInt64) : UInt64 :=
  let bootInfo : BootInfo.Ptr := { addr := bootInfoAddr }
  let responseAddr := BootInfo.framebufferResponse bootInfo
  if responseAddr == (0 : UInt64) then
    (1 : UInt64)
  else
    let response : Framebuffer.ResponsePtr := { addr := responseAddr }
    if Framebuffer.responseFramebufferCount response == (0 : UInt64) then
      (2 : UInt64)
    else
      let fb := Framebuffer.firstFramebuffer response
      let base := Framebuffer.address fb
      let width := Framebuffer.width fb
      let height := Framebuffer.height fb
      let pitch := Framebuffer.pitch fb
      draw base width height pitch (0 : UInt64) (0 : UInt64)

end Kernel
