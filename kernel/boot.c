#include "Limine/limine.h"

struct bootinfo {
    uint64_t framebuffer_response;
    uint64_t hhdm_response;
    uint64_t memmap_response;
};

static struct bootinfo bootinfo;
extern uint64_t kernel_entry(uint64_t bootinfo_addr);

void _start(void) {
    bootinfo.framebuffer_response = (uint64_t)limine_framebuffer_request.response;
    bootinfo.hhdm_response = (uint64_t)limine_hhdm_request.response;
    bootinfo.memmap_response = (uint64_t)limine_memmap_request.response;
    (void)kernel_entry((uint64_t)&bootinfo);
    for (;;) {}
}
