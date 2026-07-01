#include <lean/lean.h>

uint64_t arch_halt(uint64_t token) {
    __asm__ volatile ("idle 0");
    return token;
}
