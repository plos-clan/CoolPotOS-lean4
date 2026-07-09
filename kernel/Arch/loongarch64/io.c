#include <lean/lean.h>

uint8_t mmio_load8(uint64_t addr) {
    return *(volatile uint8_t *)addr;
}

uint8_t mmio_store8(uint64_t addr, uint8_t value) {
    *(volatile uint8_t *)addr = value;
    __asm__ volatile ("dbar 0" ::: "memory");
    return value;
}
