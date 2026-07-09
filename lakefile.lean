import Lake
open Lake DSL System

package "CoolPotOS-lean4" where
lean_lib Kernel where globs := #[.submodules `kernel]

structure BuildArch where
  name : String
  efi : String
  cflags : Array String
  qemu : Array String

def selectedArch : IO BuildArch := do
  match <- IO.getEnv "ARCH" with
  | some "x86_64" => pure {
      name := "x86_64", efi := "BOOTX64.EFI",
      cflags := #[
        "-m64", "-mcmodel=kernel", "-mgeneral-regs-only", "-mno-red-zone"
      ],
      qemu := #["-M", "q35", "-cpu", "host", "-accel", "kvm"]
    }
  | some "loongarch64" => pure {
      name := "loongarch64", efi := "BOOTLOONGARCH64.EFI",
      cflags := #["-mcmodel=medium", "-msoft-float"],
      qemu := #["-M", "virt", "-cpu", "la464", "-device", "ramfb"]
    }
  | _ => throw <| IO.userError "unsupported architecture"

target kernel pkg : FilePath := do
  let arch <- selectedArch
  let dep <- pkg.fetchTargetJob `Kernel
  Job.async (caption := s!"kernel {arch.name}") do
    let _ <- dep.await
    let dir := FilePath.mk s!".lake/{arch.name}"
    let objDir := dir / "obj"

    if <- objDir.pathExists then
      IO.FS.removeDirAll objDir

    let leanPrefix := FilePath.mk <|
      <- captureProc {cmd := "lean", args := #["--print-prefix"]}
    let cflags := #[
      "-O3", "-ffunction-sections", "-fdata-sections", "-nostdinc",
      "-ffreestanding", "-fno-builtin", "-fno-stack-protector", "-DNDEBUG",
      "-I", (leanPrefix / "include").toString,
      "-isystem", (leanPrefix / "include/clang").toString,
      "-target", s!"{arch.name}-unknown-none"
    ] ++ arch.cflags

    let archDir := s!"kernel/Arch/{arch.name}/"
    let sourceRoots := #[
      (".lake/build/ir/kernel" : FilePath),
      "kernel"
    ]
    let sources <- sourceRoots.flatMapM fun root => root.walkDir
    let sources := sources.filter fun path =>
      let pathString := path.toString
      path.extension == some "c"
        && (!pathString.contains "kernel/Arch/"
          || pathString.contains archDir)
    let objs <- sources.mapM fun source => do
      let obj := objDir / source.withExtension "o"
      compileO obj source cflags "clang"
      pure obj

    let kernel := dir / "kernel.elf"
    let linkArgs := objs.map (fun obj => obj.toString) ++ #[
      s!"libs/{arch.name}/liballoc.a", "-nostdlib", "-static",
      "--gc-sections", "-s", "-T", s!"assets/linkers/{arch.name}.ld",
      "-o", kernel.toString
    ]
    proc {cmd := "ld.lld", args := linkArgs}
    pure kernel

@[default_target]
target image : FilePath := do
  let arch <- selectedArch
  let kernelJob <- kernel.fetch
  Job.async (caption := s!"image {arch.name}") do
    let kernel <- kernelJob.await
    let dir := FilePath.mk s!".lake/{arch.name}"
    let image := dir / s!"CoolPotOS-{arch.name}.img"
    let imageArgs := #[
      "-o", image.toString, "-f", s!"{kernel}:kernel",
      "-f", "assets/limine/limine.conf:limine.conf",
      "-f", s!"assets/limine/{arch.efi}:efi/boot/{arch.efi}"
    ]
    proc {cmd := "assets/tools/oib", args := imageArgs}
    pure image

@[default_script]
script run do
  let arch <- selectedArch
  let image <- runBuild image.fetch
  let qemuArgs := #[
    "-no-reboot", "-serial", "stdio",
    "-drive", s!"if=pflash,format=raw,file=assets/firmware/{arch.name}.fd",
    "-device", "nvme,drive=disk,serial=deadbeef",
    "-drive", s!"if=none,id=disk,format=raw,file={image}"
  ] ++ arch.qemu
  let child <- IO.Process.spawn {cmd := s!"qemu-system-{arch.name}", args := qemuArgs}
  return <- child.wait
