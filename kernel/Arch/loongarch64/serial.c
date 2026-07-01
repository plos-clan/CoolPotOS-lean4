#include <lean/lean.h>

uint64_t serial_init(uint64_t token) {
    return token;
}

uint64_t serial_write_byte(uint8_t value, uint64_t token) {
    (void)value;
    return token;
}
