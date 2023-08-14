MEMORY
{
    BOOTROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x00020000
    APPROM (rx) : ORIGIN = 0x00020000, LENGTH = 0x00020000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

__bootrom_start__ = ORIGIN(BOOTROM);
__bootrom_size__ = LENGTH(BOOTROM);
__approm_start__ = ORIGIN(APPROM);
__approm_size__ = LENGTH(APPROM);