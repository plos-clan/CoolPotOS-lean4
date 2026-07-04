prelude
import Init.Prelude
import Init.Data.ToString.Basic
import Init.Data.UInt.Basic
import kernel.Utils.Format

namespace Kernel.Memory.Address

def canonicalMask : UInt64 := 0xffff800000000000
def physicalUpperMask : UInt64 := 0xfff0000000000000

def isCanonical (addr : UInt64) : Bool :=
  let masked := addr &&& canonicalMask
  masked == 0 || masked == canonicalMask

def isPhysical (addr : UInt64) : Bool :=
  addr &&& physicalUpperMask == 0

structure RawAddr where
  value : UInt64

structure VirtAddr where
  value : UInt64
  valid : isCanonical value = true

structure PhysAddr where
  value : UInt64
  valid : isPhysical value = true

namespace RawAddr

def null : RawAddr := { value := 0 }
def isNull (addr : RawAddr) : Bool := addr.value == 0

end RawAddr

namespace VirtAddr

def of? (value : UInt64) : Option VirtAddr :=
  if h : isCanonical value = true then
    some { value, valid := h }
  else
    none

def raw (addr : VirtAddr) : RawAddr := { value := addr.value }

end VirtAddr

namespace PhysAddr

def of? (value : UInt64) : Option PhysAddr :=
  if h : isPhysical value = true then
    some { value, valid := h }
  else
    none

def raw (addr : PhysAddr) : RawAddr := { value := addr.value }

def toVirt? (addr : PhysAddr) (hhdm : VirtAddr) : Option VirtAddr :=
  VirtAddr.of? (addr.value + hhdm.value)

end PhysAddr

namespace VirtAddr

def toPhys? (addr hhdm : VirtAddr) : Option PhysAddr :=
  if addr.value < hhdm.value then
    none
  else
    PhysAddr.of? (addr.value - hhdm.value)

end VirtAddr

instance : ToString RawAddr where
  toString addr := Utils.Format.hex64 addr.value

instance : ToString VirtAddr where
  toString addr := Utils.Format.hex64 addr.value

instance : ToString PhysAddr where
  toString addr := Utils.Format.hex64 addr.value

end Kernel.Memory.Address
