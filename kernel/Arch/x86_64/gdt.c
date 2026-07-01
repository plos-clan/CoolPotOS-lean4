#include <lean/lean.h>

struct __attribute__((packed)) descriptor_pointer {
    uint16_t limit;
    uint64_t base;
};

static uint64_t gdt_entries[7];
static struct descriptor_pointer gdt_pointer;
static uint8_t tss[104];
static uint8_t tss_stack[4096];

uint64_t gdt_base(uint64_t token) {
    (void)token;
    return (uint64_t)gdt_entries;
}

uint64_t gdt_pointer_addr(uint64_t token) {
    (void)token;
    return (uint64_t)&gdt_pointer;
}

uint64_t tss_base(uint64_t token) {
    (void)token;
    return (uint64_t)tss;
}

uint64_t tss_stack_addr(uint64_t token) {
    (void)token;
    return (uint64_t)tss_stack;
}

uint64_t load_gdt(uint64_t pointer, uint64_t token) {
    __asm__ volatile (
        "lgdt (%0)\n"
        "pushq $0x08\n"
        "leaq 1f(%%rip), %%rax\n"
        "pushq %%rax\n"
        "lretq\n"
        "1:\n"
        "movw $0x10, %%ax\n"
        "movw %%ax, %%ds\n"
        "movw %%ax, %%es\n"
        "movw %%ax, %%fs\n"
        "movw %%ax, %%gs\n"
        "movw %%ax, %%ss\n"
        :
        : "r"(pointer)
        : "rax", "memory"
    );
    return token;
}

uint64_t load_tss(uint16_t selector, uint64_t token) {
    __asm__ volatile ("ltr %0" :: "r"(selector) : "memory");
    return token;
}
