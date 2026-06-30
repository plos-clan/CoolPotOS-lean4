# CoolPotOS Lean4

This is a simple operating system for `x86_64` and `loongarch64` written in Lean4.

## Build

Install Lean4 with `elan`, and ensure `clang`, `ld.lld`, and QEMU are available.

**Available targets:**
- `make`: Build the disk image
- `make run`: Build and run the disk image in QEMU
- `make clean`: Remove the build directory

Use `ARCH=x86_64` or `ARCH=loongarch64` to specify the architecture.

## License

The project follows MIT license. Anyone can use it for free. See [LICENSE](LICENSE).
