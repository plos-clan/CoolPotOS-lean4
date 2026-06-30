typedef unsigned long long u64;

struct limine_framebuffer_response;

struct limine_framebuffer_request {
    u64 id[4];
    u64 revision;
    struct limine_framebuffer_response *response;
};

extern volatile struct limine_framebuffer_request limine_framebuffer_request;
