#include <lean/lean.h>

static uint8_t ready;
static uint64_t base = 0x1fe001e0;

static uint8_t mmio_read8(uint64_t addr) {
    return *(volatile uint8_t *)addr;
}

static void mmio_write8(uint64_t addr, uint8_t value) {
    *(volatile uint8_t *)addr = value;
    __asm__ volatile ("dbar 0" ::: "memory");
}

uint64_t serial_init(uint64_t token) {
    mmio_write8(base + 1, 0x00);
    mmio_write8(base + 3, 0x80);
    mmio_write8(base + 0, 0x03);
    mmio_write8(base + 1, 0x00);
    mmio_write8(base + 3, 0x03);
    mmio_write8(base + 2, 0xc7);
    mmio_write8(base + 4, 0x0b);
    ready = 1;
    return token;
}

uint64_t serial_write_byte(uint8_t value, uint64_t token) {
    if (ready == 0) {
        return token;
    }

    while ((mmio_read8(base + 5) & 0x20) == 0) {}
    mmio_write8(base, value);
    return token;
}
