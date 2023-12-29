/* Linker script for your embedded system */

MEMORY
{
    BOOTROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x00018000
    SHARED (rx) : ORIGIN = 0x00018000, LENGTH = 0x00017000
    APP_HEADER (rwx) : ORIGIN = 0x00029000, LENGTH = 0x00001000
    APPROM (rx) : ORIGIN = 0x00030000, LENGTH = 0x00010000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00002000
    BOOTSRAM (rwx) : ORIGIN = 0x20002000, LENGTH = 0x00002000
    APPSRAM (rwx) : ORIGIN = 0x20004000, LENGTH = 0x00002000
    SHAREDSRAM (rwx) : ORIGIN = 0x20006000, LENGTH = 0x00002000
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

_appstack = ORIGIN(APPSRAM) + LENGTH(APPSRAM);
_heap_start = .; /* Adjust this based on your requirements */
_heap_end = ORIGIN(APPSRAM) + LENGTH(APPSRAM);


SECTIONS
{
    .init_array :
    {
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(SORT_BY_INIT_PRIORITY(.ctors.*)))
    } > BOOTROM

    .text :
    {
        _boottext = .;
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        _bootetext = .;
    } > BOOTROM

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _bootdata = .;
        _bootldata = LOADADDR (.data);
        *(vtable)
        *(.data*)
        _bootedata = .;
    } > BOOTSRAM

    .bss :
    {
        _bootbss = .;
        *(.bss*)
        *(COMMON)
        _bootebss = .;
    } > BOOTSRAM

    .fini_array :
    {
        KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
        KEEP(*(SORT_BY_INIT_PRIORITY(.dtors.*)))
        _fini = .;
    } > BOOTROM
}

PROVIDE (_bootestack = ORIGIN(APPSRAM) + LENGTH(APPSRAM));