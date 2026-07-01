prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Utils.Memory

namespace Arch.x86_64.Gdt

open Kernel.Utils.Memory (KernelM)
open Kernel.Utils.Memory.KernelM (run store16 store32 store64)

@[extern "gdt_base"]
opaque entries : UInt64 -> UInt64

@[extern "gdt_pointer_addr"]
opaque pointer : UInt64 -> UInt64

@[extern "tss_base"]
opaque tss : UInt64 -> UInt64

@[extern "tss_stack_addr"]
opaque tssStack : UInt64 -> UInt64

@[extern "load_gdt"]
opaque loadGdt : UInt64 -> UInt64 -> UInt64

@[extern "load_tss"]
opaque loadTss : UInt16 -> UInt64 -> UInt64

def tssDescriptorLow (base : UInt64) : UInt64 :=
  let limit : UInt64 := 103
  let lowBase := (base &&& 0x00ffffff) <<< 16
  let midBase := ((base >>> 24) &&& 0xff) <<< 56
  let access := 0x0000890000000000
  lowBase ||| midBase ||| limit ||| access

@[inline] def writeTss (addr stackTop : UInt64) : KernelM Unit := do
  store32 addr 0
  store64 (addr + 4) 0
  store64 (addr + 12) 0
  store64 (addr + 20) 0
  store64 (addr + 28) 0
  store64 (addr + 36) stackTop
  store64 (addr + 44) 0
  store64 (addr + 52) 0
  store64 (addr + 60) 0
  store64 (addr + 68) 0
  store64 (addr + 76) 0
  store64 (addr + 84) 0
  store64 (addr + 92) 0
  store16 (addr + 100) 0
  store16 (addr + 102) 0

def init : UInt64 -> UInt64 := run do
  let token <- get
  let gdt := entries token
  let gdtr := pointer token
  let tssAddr := tss token
  let stackTop := tssStack token + 4096
  store64 gdt 0x0000000000000000
  store64 (gdt + 8) 0x00a09a0000000000
  store64 (gdt + 16) 0x00c0920000000000
  store64 (gdt + 24) 0x00c0f20000000000
  store64 (gdt + 32) 0x00a0fa0000000000
  store64 (gdt + 40) (tssDescriptorLow tssAddr)
  store64 (gdt + 48) (tssAddr >>> 32)
  store16 gdtr 55
  store64 (gdtr + 2) gdt
  writeTss tssAddr stackTop
  modify (loadGdt gdtr)
  modify (loadTss 0x28)

end Arch.x86_64.Gdt
