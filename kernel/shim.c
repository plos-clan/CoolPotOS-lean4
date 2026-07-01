#include <lean/lean.h>

void *mi_malloc_small(size_t size) { return malloc(size); }
void lean_dec_ref_cold(lean_object *ptr) { free(ptr); }
void lean_inc_heartbeat(void) {}
void lean_internal_panic_out_of_memory(void) { for (;;); }
void lean_internal_panic_overflow(void) { for (;;); }

lean_object *lean_alloc_object(size_t size) {
    void *obj = malloc(size);
    if (!obj) lean_internal_panic_out_of_memory();
    return obj;
}

lean_object *lean_string_append(lean_object *left, lean_object *right) {
    size_t l_size = lean_string_size(left) - 1;
    size_t r_size = lean_string_size(right);
    size_t len = lean_string_len(left) + lean_string_len(right);

    lean_object *res = lean_alloc_string(l_size + r_size, l_size + r_size, len);
    char *data = lean_to_string(res)->m_data;

    __builtin_memcpy(data, lean_string_cstr(left), l_size);
    __builtin_memcpy(data + l_size, lean_string_cstr(right), r_size);
    return res;
}
