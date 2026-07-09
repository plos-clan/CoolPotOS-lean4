prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Arch.x86_64.Cpu
import kernel.Arch.x86_64.Port
import kernel.Drivers.Serial.Device
import kernel.Drivers.Serial.Ns16550

namespace Arch.x86_64.Serial

open Kernel.Driver.Serial

private def base : UInt16 := 0x3f8

instance : Ns16550.RegisterIO Arch.x86_64.Arch where
  read offset := Port.in8 (base + offset.toUInt16)
  write offset value token := Port.out8 (base + offset.toUInt16) value token

instance : Device Arch.x86_64.Arch where
  init := Ns16550.init (Arch := Arch.x86_64.Arch)
  writeByte := Ns16550.writeByte (Arch := Arch.x86_64.Arch)

end Arch.x86_64.Serial
