ARCH ?= x86_64
BUILD_DIR := .lake/$(ARCH)
KERNEL := $(BUILD_DIR)/kernel.elf
OUTPUT_IMG := $(BUILD_DIR)/CoolPotOS-$(ARCH).img

C_SRCS := $(sort $(shell find kernel -name '*.c' ! -path 'kernel/Arch/*' -print))
C_SRCS += $(sort $(wildcard kernel/Arch/$(ARCH)/*.c))
C_OBJS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SRCS))

LEAN_SRCS := $(sort $(shell find kernel -name '*.lean' ! -path 'kernel/Arch/*' -print))
LEAN_SRCS += $(sort $(wildcard kernel/Arch/$(ARCH)/*.lean))
LEAN_MODULES := $(patsubst %.lean,%,$(LEAN_SRCS))
LEAN_IR_SRCS = $(wildcard $(addprefix .lake/build/ir/,$(addsuffix .c,$(LEAN_MODULES))))
LEAN_OBJS = $(patsubst .lake/build/ir/%.c,$(BUILD_DIR)/%.o,$(LEAN_IR_SRCS))

LEAN_PREFIX := $(shell lake env lean --print-prefix)
CFLAGS := -O3 -ffunction-sections -fdata-sections
CFLAGS += -nostdinc -ffreestanding -fno-builtin -fno-stack-protector -DNDEBUG
LEANFLAGS = $(CFLAGS) -I $(LEAN_PREFIX)/include -isystem $(LEAN_PREFIX)/include/clang
LDFLAGS := -nostdlib -static --gc-sections -s -T assets/linkers/$(ARCH).ld
LIBS := libs/$(ARCH)/liballoc.a

QEMUFLAGS := -no-reboot -serial stdio
QEMUFLAGS += -drive if=pflash,format=raw,file=assets/firmware/$(ARCH).fd
QEMUFLAGS += -device nvme,drive=disk,serial=deadbeef
QEMUFLAGS += -drive if=none,id=disk,format=raw,file=$(OUTPUT_IMG)

ifeq ($(ARCH), x86_64)
	CFLAGS += -target x86_64-unknown-none
	CFLAGS += -m64 -mcmodel=kernel -mgeneral-regs-only -mno-red-zone
	QEMUFLAGS += -M q35 -cpu host -accel kvm
	EFI_NAME := BOOTX64.EFI
	ARCH_TARGET := KernelArchX86_64
else ifeq ($(ARCH), loongarch64)
	CFLAGS += -target loongarch64-unknown-none
	CFLAGS += -mcmodel=medium -msoft-float
	QEMUFLAGS += -M virt -cpu la464 -device ramfb
	EFI_NAME := BOOTLOONGARCH64.EFI
	ARCH_TARGET := KernelArchLoongArch64
else
	$(error Unsupported architecture: $(ARCH))
endif

.PHONY: default kernel image run clean

default: image

run: image
	@qemu-system-$(ARCH) $(QEMUFLAGS)

clean:
	@rm -rf $(BUILD_DIR)

$(BUILD_DIR)/%.o: .lake/build/ir/%.c
	@mkdir -p $(@D)
	@clang $(LEANFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	@clang $(LEANFLAGS) -c $< -o $@

kernel:
	@mkdir -p $(dir $(KERNEL))
	@lake build $(ARCH_TARGET)
	@$(MAKE) -s $(LEAN_OBJS) $(C_OBJS) ARCH=$(ARCH)
	@ld.lld $(LEAN_OBJS) $(C_OBJS) $(LIBS) $(LDFLAGS) -o $(KERNEL)

image: kernel
	@chmod +x assets/tools/oib
	@assets/tools/oib -o $(OUTPUT_IMG) -f $(KERNEL):kernel \
		-f assets/limine/limine.conf:limine.conf \
		-f assets/limine/$(EFI_NAME):efi/boot/$(EFI_NAME)
