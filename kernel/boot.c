#include "Limine/limine.h"

struct bootinfo {
    u64 framebuffer_response;
};

extern u64 lean_kernel_start(u64 bootinfo_addr);

static struct bootinfo bootinfo;

void _start(void) {
    bootinfo.framebuffer_response = (u64)limine_framebuffer_request.response;
    (void)lean_kernel_start((u64)&bootinfo);

    for (;;) {
    }
}
