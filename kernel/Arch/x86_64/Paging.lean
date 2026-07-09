prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Arch.x86_64.Cpu
import kernel.Memory.Address
import kernel.Memory.Hhdm
import kernel.Memory.Paging.Walk

namespace Arch.x86_64.Paging

open Kernel.Memory.Address
open Kernel.Memory.Paging

inductive Level where
  | pgd | pud | pmd | pte

instance : PageTableFormat Arch where
  indexMask := 0x1ff
  addrMask := 0x000f_ffff_ffff_f000
  present := 1
  huge := 0x80
  parentFlags := 0x7
  kernelDataFlags := 0x8000000000000003
  tableBytes := 4096

instance : Root Level.pgd Level.pte 12 where
instance : Next Level.pgd Level.pud 39 where
instance : Next Level.pud Level.pmd 30 where
instance : Next Level.pmd Level.pte 21 where
instance : Leaf 12 Level.pte 0 where
instance : Leaf 21 Level.pmd 0x80 where
instance : Leaf 30 Level.pud 0x80 where

@[extern "read_cr3"]
opaque readCr3 : UInt64 -> UInt64

@[extern "write_cr3"]
opaque writeCr3 : UInt64 -> UInt64 -> UInt64

@[extern "invlpg"]
opaque invlpg : UInt64 -> UInt64 -> UInt64

instance : PageInvalidation Arch where
  invalidatePage := invlpg

def root (hhdm : RawAddr) (token : UInt64) : Table Arch Level.pgd :=
  { addr := Kernel.Memory.Hhdm.RawAddr.toVirt { value := readCr3 token } hhdm }

end Arch.x86_64.Paging
