prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Limine.BootInfo
import kernel.Drivers.Serial.Device
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

def main {Arch Level : Type} {root native : Level} {shift : UInt64}
    [Serial.Device Arch] [Paging.PageTableFormat Arch] [Paging.PageInvalidation Arch]
    [Paging.Root root native shift] [Paging.Walk root native shift]
    (bootInfoAddr token : UInt64) (rootTable : Paging.Table Arch root) : UInt64 := Id.run do
  let mut token := Serial.writeLine (Arch := Arch) "CoolPotOS Lean4"
    (Serial.Device.init (Arch := Arch) token)
  let bootInfo : RawAddr := { value := bootInfoAddr }
  let hhdmResponse := BootInfo.hhdmResponse bootInfo
  let memmapResponse := BootInfo.memmapResponse bootInfo

  token :=
    if hhdmResponse.value == 0 || memmapResponse.value == 0 then
      Serial.writeLine (Arch := Arch) "Error: HHDM or Memmap response missing" token
    else
      let allocator := FrameAllocator.init hhdmResponse memmapResponse
      if allocator.isNull then
        Serial.writeLine (Arch := Arch) "Error: FrameAllocator init failed" token
      else
        let frame := FrameAllocator.alloc allocator 1
        let heap := Heap.init hhdmResponse allocator rootTable token
        let frames := FrameAllocator.usableFrames allocator
        let message :=
          s!"mem hhdm={hhdmResponse} memmap={memmapResponse} allocator={allocator} " ++
          s!"frames={Format.dec64 frames} frame={frame} heap={Format.dec64 heap}"
        Serial.writeLine (Arch := Arch) message token
  return token

def mainNoHeap {Arch : Type} [Serial.Device Arch]
    (bootInfoAddr token : UInt64) : UInt64 := Id.run do
  let mut token := Serial.writeLine (Arch := Arch) "CoolPotOS Lean4"
    (Serial.Device.init (Arch := Arch) token)
  let bootInfo : RawAddr := { value := bootInfoAddr }
  let hhdmResponse := BootInfo.hhdmResponse bootInfo
  let memmapResponse := BootInfo.memmapResponse bootInfo

  token :=
    if hhdmResponse.value == 0 || memmapResponse.value == 0 then
      Serial.writeLine (Arch := Arch) "Error: HHDM or Memmap response missing" token
    else
      let allocator := FrameAllocator.init hhdmResponse memmapResponse
      if allocator.isNull then
        Serial.writeLine (Arch := Arch) "Error: FrameAllocator init failed" token
      else
        Serial.writeLine (Arch := Arch) "mem init ok heap=0" token
  return token

end Kernel
