MEMORY
{
    BOOTROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x00018000
    SHARED (rx) : ORIGIN = 0x00018000, LENGTH = 0x00018000
    APPROM (rx) : ORIGIN = 0x00030000, LENGTH = 0x00020000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

__bootrom_start__ = ORIGIN(BOOTROM);
__bootrom_size__ = LENGTH(BOOTROM);
__shared_start__ = ORIGIN(BOOTROM);
__shared_size__ = LENGTH(BOOTROM);
__approm_start__ = ORIGIN(APPROM);
__approm_size__ = LENGTH(APPROM);