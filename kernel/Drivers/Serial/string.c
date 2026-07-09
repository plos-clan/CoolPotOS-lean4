#include <lean/lean.h>

uint64_t serial_string_size(lean_object *text) {
    return lean_string_size(text) - 1;
}

uint8_t serial_string_byte(lean_object *text, uint64_t index) {
    return (uint8_t)lean_string_cstr(text)[index];
}
