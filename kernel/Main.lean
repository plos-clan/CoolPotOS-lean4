prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Limine.BootInfo
import kernel.Drivers.Serial
import kernel.Memory.Address
import kernel.Memory.FrameAllocator
import kernel.Memory.Hhdm
import kernel.Memory.Heap
import kernel.Utils.Format

namespace Kernel

open Kernel.Driver
open Kernel.Limine
open Kernel.Memory
open Kernel.Memory.Address
open Kernel.Utils

def main (bootInfoAddr token : UInt64) : UInt64 := Id.run do
  let mut token := Serial.writeStarted (Serial.init token)
  let bootInfo : RawAddr := { value := bootInfoAddr }
  let hhdmResponse := BootInfo.hhdmResponse bootInfo
  let memmapResponse := BootInfo.memmapResponse bootInfo

  token :=
    if hhdmResponse.value == 0 || memmapResponse.value == 0 then
      Serial.writeLine "Error: HHDM or Memmap response missing" token
    else
      let allocator := FrameAllocator.init hhdmResponse memmapResponse
      if allocator.isNull then
        Serial.writeLine "Error: FrameAllocator init failed" token
      else
        let frame := FrameAllocator.alloc allocator 1
        let heap := Heap.init hhdmResponse allocator
        let frames := FrameAllocator.usableFrames allocator
        let message :=
          s!"mem hhdm={hhdmResponse} memmap={memmapResponse} allocator={allocator} " ++
          s!"frames={Format.dec64 frames} frame={frame} heap={Format.dec64 heap}"
        Serial.writeLine message token
  return token

end Kernel
