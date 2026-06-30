typedef unsigned long long u64;

struct limine_framebuffer_response;
struct limine_hhdm_response;
struct limine_memmap_response;

struct limine_framebuffer_request {
    u64 id[4];
    u64 revision;
    struct limine_framebuffer_response *response;
};

struct limine_hhdm_request {
    u64 id[4];
    u64 revision;
    struct limine_hhdm_response *response;
};

struct limine_memmap_request {
    u64 id[4];
    u64 revision;
    struct limine_memmap_response *response;
};

extern volatile struct limine_framebuffer_request limine_framebuffer_request;
extern volatile struct limine_hhdm_request limine_hhdm_request;
extern volatile struct limine_memmap_request limine_memmap_request;
