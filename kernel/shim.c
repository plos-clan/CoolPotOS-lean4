#include <lean/lean.h>

void *mi_malloc_small(size_t size) { return malloc(size); }
void lean_dec_ref_cold(lean_object *ptr) { free(ptr); }
void lean_inc_heartbeat(void) {}
void lean_internal_panic_out_of_memory(void) { for (;;); }
void lean_internal_panic_overflow(void) { for (;;); }

static int scalar_once_claim(lean_once_cell_t *cell) {
    int expected = 0;
    return __c11_atomic_compare_exchange_strong(
        &cell->state,
        &expected,
        2,
        __ATOMIC_ACQUIRE,
        __ATOMIC_RELAXED);
}

static void scalar_once_publish(lean_once_cell_t *cell) {
    __c11_atomic_store(&cell->state, 1, __ATOMIC_RELEASE);
}

static void scalar_once_wait(lean_once_cell_t *cell) {
    while (__c11_atomic_load(&cell->state, __ATOMIC_ACQUIRE) != 1) {}
}

#define DEFINE_SCALAR_ONCE_COLD(type, name) \
    type name(type *loc, lean_once_cell_t *cell, type (*init)(void)) { \
        if (scalar_once_claim(cell)) { \
            type value = init(); \
            *loc = value; \
            scalar_once_publish(cell); \
            return value; \
        } \
        scalar_once_wait(cell); \
        return *loc; \
    }

DEFINE_SCALAR_ONCE_COLD(uint8_t, lean_uint8_once_cold)
DEFINE_SCALAR_ONCE_COLD(uint16_t, lean_uint16_once_cold)
DEFINE_SCALAR_ONCE_COLD(uint32_t, lean_uint32_once_cold)
DEFINE_SCALAR_ONCE_COLD(uint64_t, lean_uint64_once_cold)
DEFINE_SCALAR_ONCE_COLD(size_t, lean_usize_once_cold)

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
