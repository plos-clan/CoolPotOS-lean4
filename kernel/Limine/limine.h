#include <lean/lean.h>

struct limine_framebuffer_response;
struct limine_hhdm_response;
struct limine_memmap_response;

struct limine_framebuffer_request {
    uint64_t id[4];
    uint64_t revision;
    struct limine_framebuffer_response *response;
};

struct limine_hhdm_request {
    uint64_t id[4];
    uint64_t revision;
    struct limine_hhdm_response *response;
};

struct limine_memmap_request {
    uint64_t id[4];
    uint64_t revision;
    struct limine_memmap_response *response;
};

extern volatile struct limine_framebuffer_request limine_framebuffer_request;
extern volatile struct limine_hhdm_request limine_hhdm_request;
extern volatile struct limine_memmap_request limine_memmap_request;
