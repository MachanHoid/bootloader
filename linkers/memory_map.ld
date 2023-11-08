MEMORY
{
    BOOTROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x00018000
    SHARED (rx) : ORIGIN = 0x00018000, LENGTH = 0x00017000
    APP_HEADER (rwx) : ORIGIN = 0x00029000, LENGTH = 0x00001000
    APPROM (rx) : ORIGIN = 0x00030000, LENGTH = 0x00010000
    SHAREDSRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00001000
    BOOTSRAM (rwx) : ORIGIN = 0x20001000, LENGTH = 0x00000500
    APPSRAM (rwx) : ORIGIN = 0x20001500, LENGTH = 0x00000500
    SRAM (rwx) : ORIGIN = 0x20002000, LENGTH = 0x00006000
}

__bootrom_start__ = ORIGIN(BOOTROM);
__bootrom_size__ = LENGTH(BOOTROM);
__shared_start__ = ORIGIN(SHARED);
__shared_size__ = LENGTH(SHARED);
__appheader_start__ = ORIGIN(APP_HEADER);
__appheader_size__ = LENGTH(APP_HEADER);
__approm_start__ = ORIGIN(APPROM);
__approm_size__ = LENGTH(APPROM);

__sram_start__ = ORIGIN(SRAM);
__sram_size__ = LENGTH(SRAM);
__bootsram_start__ = ORIGIN(BOOTSRAM);
__bootsram_size__ = LENGTH(BOOTSRAM);
__appsram_start__ = ORIGIN(APPSRAM);
__appsram_size__ = LENGTH(APPSRAM);
__sharedsram_start__ = ORIGIN(SHAREDSRAM);
__sharedsram_size__ = LENGTH(SHAREDSRAM);