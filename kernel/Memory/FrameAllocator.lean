prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Utils.Bitmap
import kernel.Memory.Address
import kernel.Memory.Hhdm
import kernel.Memory.Memmap
import kernel.Utils.Memory

namespace Kernel.Memory.FrameAllocator

open Kernel.Memory.Address
open Kernel.Utils.Memory (load64)
open Kernel.Utils.Memory.KernelM (run store64)

def pageSize : UInt64 := 4096
def entryUsable : UInt64 := 0
def notFound : UInt64 := 0xffffffffffffffff
def structSize : UInt64 := 24

def bitmapAddr (allocator : RawAddr) : UInt64 :=
  load64 allocator.value

def bitmapLen (allocator : RawAddr) : UInt64 :=
  load64 (allocator.value + 8)

def usableFrames (allocator : RawAddr) : UInt64 :=
  load64 (allocator.value + 16)

def alignUp (value align : UInt64) : UInt64 :=
  (value + align - 1) &&& ~~~(align - 1)

def divCeil (value divisor : UInt64) : UInt64 :=
  (value + divisor - 1) / divisor

partial def memorySize (memmap : RawAddr) (index count size : UInt64) : UInt64 :=
  if index == count then
    size
  else
    let entry := Memmap.memmapEntry memmap index
    let nextSize :=
      if Memmap.memmapEntryType entry == entryUsable then
        let endAddr := Memmap.memmapEntryBase entry + Memmap.memmapEntryLength entry
        if endAddr > size then endAddr else size
      else
        size
    memorySize memmap (index + 1) count nextSize

partial def findBitmapStorage
    (memmap : RawAddr) (index count requiredBytes : UInt64) : UInt64 :=
  if index == count then
    notFound
  else
    let entry := Memmap.memmapEntry memmap index
    if
        Memmap.memmapEntryType entry == entryUsable &&
        Memmap.memmapEntryLength entry >= requiredBytes then
      Memmap.memmapEntryBase entry
    else
      findBitmapStorage memmap (index + 1) count requiredBytes

partial def releaseUsableFrames
    (memmap : RawAddr) (bitmap bitmapLen index count released token : UInt64) : UInt64 :=
  if index == count then
    released + token - token
  else
    let entry := Memmap.memmapEntry memmap index
    if Memmap.memmapEntryType entry == entryUsable then
      let startFrame := Memmap.memmapEntryBase entry / pageSize
      let frameCount := Memmap.memmapEntryLength entry / pageSize
      let token :=
        Utils.Bitmap.setRange bitmap bitmapLen startFrame (startFrame + frameCount) true token
      let released := released + frameCount
      releaseUsableFrames memmap bitmap bitmapLen (index + 1) count released token
    else
      releaseUsableFrames memmap bitmap bitmapLen (index + 1) count released token

def init (hhdm : RawAddr) (memmap : RawAddr) : RawAddr :=
  let count := Memmap.memmapEntryCount memmap
  let size := memorySize memmap 0 count 0
  let bitmapBytes := divCeil (size / pageSize) 8
  let requiredBytes := alignUp (structSize + bitmapBytes) pageSize
  let storagePhys := findBitmapStorage memmap 0 count requiredBytes
  if storagePhys == notFound then
    RawAddr.null
  else
    let storage := (Hhdm.RawAddr.toVirt { value := storagePhys } hhdm).value
    let bitmap := storage + structSize
    let bitmapLen := bitmapBytes * 8
    let token := Utils.Bitmap.clearBytes bitmap bitmapBytes 0 storage
    let released :=
      releaseUsableFrames memmap bitmap bitmapLen 0 count 0 token
    let bitmapFrameStart := storagePhys / pageSize
    let bitmapFrameCount := divCeil requiredBytes pageSize
    let bitmapFrameEnd := bitmapFrameStart + bitmapFrameCount
    let token :=
      Utils.Bitmap.setRange bitmap bitmapLen bitmapFrameStart bitmapFrameEnd false released
    let usable := released - bitmapFrameCount
    let token := run (do
      store64 storage bitmap
      store64 (storage + 8) bitmapLen
      store64 (storage + 16) usable) token
    { value := storage + token - token }

def alloc (allocator : RawAddr) (count : UInt64) : RawAddr :=
  if count == 0 then
    RawAddr.null
  else
    let addr := bitmapAddr allocator
    let len := bitmapLen allocator
    let frame := Utils.Bitmap.findRange addr len count true
    if frame == len then
      RawAddr.null
    else
      let token := Utils.Bitmap.setRange addr len frame (frame + count) false frame
      let usable := usableFrames allocator - count
      let token := run (store64 (allocator.value + 16) usable) token
      { value := frame * pageSize + token - token }

end Kernel.Memory.FrameAllocator
