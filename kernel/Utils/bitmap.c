#include <lean/lean.h>

uint64_t bit_ctz64(uint64_t value) {
    return value == 0 ? 64 : __builtin_ctzll(value);
}
