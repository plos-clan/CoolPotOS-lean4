#include <lean/lean.h>

void *mi_malloc_small(size_t size) { return malloc(size); }
void lean_free_object(lean_object *obj) { free(obj); }
void lean_dec_ref_cold(lean_object *ptr) { free(ptr); }
void lean_inc_heartbeat(void) {}
void lean_internal_panic_out_of_memory(void) { for (;;); }
void lean_internal_panic_overflow(void) { for (;;); }

lean_object *lean_alloc_object(size_t size) {
    void *obj = malloc(size);
    if (!obj) lean_internal_panic_out_of_memory();
    return obj;
}

lean_object *lean_obj_once_cold(
    lean_object **loc,
    lean_once_cell_t *token,
    lean_object *(*init)(void)
) {
    if (token->state == 0) {
        *loc = init();
        token->state = 1;
    }
    return *loc;
}

lean_object *lean_mk_string_from_bytes(char const *data, size_t size) {
    size_t len = 0;
    for (size_t i = 0; i < size; ++i) len += (((uint8_t)data[i] & 0xc0) != 0x80);

    lean_object *res = lean_alloc_string(size + 1, size + 1, len);
    char *tgt = lean_to_string(res)->m_data;
    __builtin_memcpy(tgt, data, size);
    tgt[size] = '\0';
    return res;
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

static lean_object *alloc_ascii_string(char const *data, size_t size) {
    lean_object *res = lean_alloc_string(size + 1, size + 1, size);
    __builtin_memcpy(lean_to_string(res)->m_data, data, size);
    lean_to_string(res)->m_data[size] = '\0';
    return res;
}

lean_object *fmt_hex64(uint64_t value) {
    char text[18];
    char const digits[] = "0123456789abcdef";
    text[0] = '0'; text[1] = 'x';
    for (int i = 0; i < 16; ++i) {
        text[i + 2] = digits[(value >> (60 - i * 4)) & 0xf];
    }
    return alloc_ascii_string(text, 18);
}

typedef struct {
    lean_object header;
    uint64_t value;
} shim_uint64_object;

lean_object *lean_big_uint64_to_nat(uint64_t value) {
    shim_uint64_object *object =
        (shim_uint64_object *)lean_alloc_object(sizeof(shim_uint64_object));
    lean_set_st_header((lean_object *)object, 0, 0);
    object->value = value;
    return (lean_object *)object;
}

lean_object *l_Nat_reprFast(lean_object *nat) {
    char buf[20];
    size_t idx = sizeof(buf);
    uint64_t v = lean_is_scalar(nat) ? lean_unbox(nat) : ((shim_uint64_object *)nat)->value;

    do {
        buf[--idx] = (char)('0' + (v % 10));
        v /= 10;
    } while (v != 0);

    return alloc_ascii_string(buf + idx, sizeof(buf) - idx);
}
