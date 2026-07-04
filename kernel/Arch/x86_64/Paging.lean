prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Memory.Address
import kernel.Memory.Hhdm
import kernel.Memory.Paging.Walk

namespace Arch.x86_64.Paging

open Kernel.Memory.Address
open Kernel.Memory.Paging

inductive Arch

inductive Level where
  | pgd | pud | pmd | pte

instance : PageTableFormat Arch where
  indexMask := 0x1ff
  addrMask := 0x000f_ffff_ffff_f000
  present := 1
  huge := 0x80
  parentFlags := 0x7

instance : Root Level.pgd where
instance : Next Level.pgd Level.pud 39 where
instance : Next Level.pud Level.pmd 30 where
instance : Next Level.pmd Level.pte 21 where
instance : Leaf Level.pte 12 0 where
instance : Leaf Level.pmd 21 0x80 where
instance : Leaf Level.pud 30 0x80 where

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
