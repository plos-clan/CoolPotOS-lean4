#include <lean/lean.h>

uint64_t serial_write_byte(uint8_t value, uint64_t token);

uint64_t serial_write_string(lean_object *text, uint64_t token) {
    char const *data = lean_string_cstr(text);
    size_t size = lean_string_size(text);

    for (size_t i = 0; i + 1 < size; ++i) {
        token = serial_write_byte((uint8_t)data[i], token);
    }

    return token;
}
