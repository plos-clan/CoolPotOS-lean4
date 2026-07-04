#include <lean/lean.h>

uint64_t read_cr3(uint64_t token) {
    (void)token;
    uint64_t value;
    __asm__ volatile ("mov %%cr3, %0" : "=r"(value));
    return value & 0x000ffffffffff000;
}

uint64_t write_cr3(uint64_t value, uint64_t token) {
    __asm__ volatile ("mov %0, %%cr3" :: "r"(value) : "memory");
    return token;
}

uint64_t invlpg(uint64_t addr, uint64_t token) {
    __asm__ volatile ("invlpg (%0)" :: "r"(addr) : "memory");
    return token;
}
