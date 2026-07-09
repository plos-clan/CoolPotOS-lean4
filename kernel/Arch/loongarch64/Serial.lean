prelude
import Init.Prelude
import Init.Data.UInt.Basic
import kernel.Arch.loongarch64.Cpu
import kernel.Arch.loongarch64.Io
import kernel.Drivers.Serial.Device
import kernel.Drivers.Serial.Ns16550

namespace Arch.loongarch64.Serial

open Kernel.Driver.Serial

private def base : UInt64 := 0x1fe001e0

instance : Ns16550.RegisterIO Arch.loongarch64.Arch where
  read offset := Io.mmioLoad8 (base + offset)
  write offset value token := Io.mmioStore8 (base + offset) value token

instance : Device Arch.loongarch64.Arch where
  init := Ns16550.init (Arch := Arch.loongarch64.Arch)
  writeByte := Ns16550.writeByte (Arch := Arch.loongarch64.Arch)

end Arch.loongarch64.Serial
