typedef unsigned int u32;
typedef unsigned long long u64;

u64 mem_load64(u64 addr) {
    return *(volatile u64 *)addr;
}

u32 mem_store32(u64 addr, u32 value) {
    *(volatile u32 *)addr = value;
    return value;
}
