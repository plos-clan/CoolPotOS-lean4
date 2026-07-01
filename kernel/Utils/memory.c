#include <lean/lean.h>

uint8_t mem_load8(uint64_t addr) {
    return *(volatile uint8_t *)addr;
}

uint64_t mem_load64(uint64_t addr) {
    return *(volatile uint64_t *)addr;
}

uint8_t mem_store8(uint64_t addr, uint8_t value) {
    *(volatile uint8_t *)addr = value;
    return value;
}

uint16_t mem_store16(uint64_t addr, uint16_t value) {
    *(volatile uint16_t *)addr = value;
    return value;
}

uint32_t mem_store32(uint64_t addr, uint32_t value) {
    *(volatile uint32_t *)addr = value;
    return value;
}

uint64_t mem_store64(uint64_t addr, uint64_t value) {
    *(volatile uint64_t *)addr = value;
    return value;
}
