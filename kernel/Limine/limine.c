#include "limine.h"

__attribute__((used, section(".limine_requests_start")))
static volatile u64 limine_requests_start_marker[] = {
    0xf6b8f4b39de7d1ae,
    0xfab91a6940fcb9cf,
    0x785c6ed015d3e316,
    0x181e920a7852b9d9,
};

__attribute__((used, section(".limine_requests")))
static volatile u64 limine_base_revision[] = {
    0xf9562b2d5c95a6c8,
    0x6a7b384944536bdc,
    3,
};

__attribute__((used, section(".limine_requests")))
volatile struct limine_framebuffer_request limine_framebuffer_request = {
    .id = {
        0xc7b1dd30df4c8b88,
        0x0a82e883a194f07b,
        0x9d5827dcd881dd75,
        0xa3148604f6fab11b,
    },
    .revision = 0,
    .response = 0,
};

__attribute__((used, section(".limine_requests_end")))
static volatile u64 limine_requests_end_marker[] = {
    0xadc0e0531bb10d03,
    0x9572709f31764c62,
};
