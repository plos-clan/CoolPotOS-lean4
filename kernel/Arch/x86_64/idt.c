#include <lean/lean.h>

struct descriptor_pointer {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));

static uint8_t idt_entries[256 * 16];
extern uint8_t interrupt_stub_base[];
void interrupt_entry(void);

extern uint64_t interrupt_common(
    uint64_t vector,
    uint64_t error_code,
    uint64_t frame
);

uint64_t idt_base(uint64_t token) {
    (void)token;
    return (uint64_t)idt_entries;
}

uint64_t load_idt(uint64_t base, uint64_t token) {
    struct descriptor_pointer pointer = { 4095, base };
    __asm__ volatile ("lidt %0" :: "m"(pointer) : "memory");
    return token;
}

uint64_t interrupt_stub(uint64_t vector, uint64_t token) {
    (void)token;
    return (uint64_t)interrupt_stub_base + vector * 10;
}

__asm__ (
    ".global interrupt_stub_base\n"
    "interrupt_stub_base:\n"
    ".set vector, 0\n"
    ".rept 256\n"
    ".byte 0x68\n"
    ".long vector\n"
    ".byte 0xe9\n"
    ".long interrupt_entry - . - 4\n"
    ".set vector, vector + 1\n"
    ".endr\n"
);

__attribute__((naked)) void interrupt_entry(void) {
    __asm__ volatile (
        "pushq %%rax\n"
        "pushq %%rcx\n"
        "pushq %%rdx\n"
        "pushq %%rbx\n"
        "pushq %%rbp\n"
        "pushq %%rsi\n"
        "pushq %%rdi\n"
        "pushq %%r8\n"
        "pushq %%r9\n"
        "pushq %%r10\n"
        "pushq %%r11\n"
        "pushq %%r12\n"
        "pushq %%r13\n"
        "pushq %%r14\n"
        "pushq %%r15\n"
        "movq 120(%%rsp), %%rdi\n"
        "xorq %%rsi, %%rsi\n"
        "leaq 128(%%rsp), %%rdx\n"
        "cmpq $8, %%rdi\n"
        "je 1f\n"
        "cmpq $10, %%rdi\n"
        "jb 2f\n"
        "cmpq $14, %%rdi\n"
        "jbe 1f\n"
        "cmpq $17, %%rdi\n"
        "je 1f\n"
        "cmpq $21, %%rdi\n"
        "je 1f\n"
        "cmpq $29, %%rdi\n"
        "jb 2f\n"
        "cmpq $30, %%rdi\n"
        "ja 2f\n"
        "1:\n"
        "movq 128(%%rsp), %%rsi\n"
        "leaq 136(%%rsp), %%rdx\n"
        "2:\n"
        "movq %%rsp, %%r11\n"
        "andq $-16, %%rsp\n"
        "subq $16, %%rsp\n"
        "movq %%r11, (%%rsp)\n"
        "callq interrupt_common\n"
        "movq (%%rsp), %%rsp\n"
        "cmpq $32, 120(%%rsp)\n"
        "jb 3f\n"
        "popq %%r15\n"
        "popq %%r14\n"
        "popq %%r13\n"
        "popq %%r12\n"
        "popq %%r11\n"
        "popq %%r10\n"
        "popq %%r9\n"
        "popq %%r8\n"
        "popq %%rdi\n"
        "popq %%rsi\n"
        "popq %%rbp\n"
        "popq %%rbx\n"
        "popq %%rdx\n"
        "popq %%rcx\n"
        "popq %%rax\n"
        "addq $8, %%rsp\n"
        "iretq\n"
        "3:\n"
        "cli\n"
        "4: hlt\n"
        "jmp 4b\n"
        ::: "memory"
    );
}
