#include <lean/lean.h>

static lean_object *alloc_ascii_string(char const *data, size_t size) {
    lean_object *res = lean_alloc_string(size + 1, size + 1, size);
    __builtin_memcpy(lean_to_string(res)->m_data, data, size);
    lean_to_string(res)->m_data[size] = '\0';
    return res;
}

lean_object *fmt_uint(uint64_t value, uint8_t base) {
    char buf[66];
    char const digits[] = "0123456789abcdef";
    size_t idx = sizeof(buf);

    do {
        buf[--idx] = digits[value % base];
        value /= base;
    } while (value != 0);

    if (base == 16) {
        buf[--idx] = 'x';
        buf[--idx] = '0';
    }

    return alloc_ascii_string(buf + idx, sizeof(buf) - idx);
}
