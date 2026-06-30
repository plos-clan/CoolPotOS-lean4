typedef unsigned long long u64;

u64 arch_halt(u64 token) {
    __asm__ volatile ("hlt");
    return token;
}
