#include <lean/lean.h>

static uint8_t ready;

static uint8_t port_in8(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static void port_out8(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" :: "a"(value), "Nd"(port));
}

uint64_t serial_init(uint64_t token) {
    port_out8(0x3f9, 0x00);
    port_out8(0x3fb, 0x80);
    port_out8(0x3f8, 0x03);
    port_out8(0x3f9, 0x00);
    port_out8(0x3fb, 0x03);
    port_out8(0x3fa, 0xc7);
    port_out8(0x3fc, 0x0b);
    port_out8(0x3fc, 0x1e);
    port_out8(0x3f8, 0xae);

    if (port_in8(0x3f8) == 0xae) {
        port_out8(0x3fc, 0x0f);
        ready = 1;
    } else {
        ready = 0;
    }

    return token;
}

uint64_t serial_write_byte(uint8_t value, uint64_t token) {
    if (ready == 0) {
        return token;
    }

    while ((port_in8(0x3fd) & 0x20) == 0) {
        __asm__ volatile ("pause");
    }
    port_out8(0x3f8, value);
    return token;
}
