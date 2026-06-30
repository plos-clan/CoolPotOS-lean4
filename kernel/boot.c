#include "Limine/limine.h"

struct bootinfo {
    u64 framebuffer_response;
    u64 hhdm_response;
    u64 memmap_response;
};

extern u64 lean_kernel_start(u64 bootinfo_addr);

static struct bootinfo bootinfo;

void _start(void) {
    bootinfo.framebuffer_response = (u64)limine_framebuffer_request.response;
    bootinfo.hhdm_response = (u64)limine_hhdm_request.response;
    bootinfo.memmap_response = (u64)limine_memmap_request.response;
    (void)lean_kernel_start((u64)&bootinfo);

    for (;;) {
    }
}
