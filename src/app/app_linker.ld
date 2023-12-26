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

_etext = _appetext; /* End of code section */
_sdata = _etext;    /* Start of data section in Flash */
_data = _appdata;   /* Start of data section in RAM */
_edata = _appedata; /* End of data section in RAM */

SECTIONS
{
    .init_array :
    {
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(SORT_BY_INIT_PRIORITY(.ctors.*)))
    } > APPROM

    .text : AT(ADDR(.init_array) + SIZEOF(.init_array))
    {
        _apptext = .;
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        _appetext = .;
    } > APPROM

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _appdata = .;
        _appldata = LOADADDR (.data);
        *(vtable)
        *(.data*)
        _appedata = .;
    } > APPSRAM

    .bss :
    {
        _appbss = .;
        *(.bss*)
        *(COMMON)
        _appebss = .;
    } > APPSRAM

    .fini_array :
    {
        KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
        KEEP(*(SORT_BY_INIT_PRIORITY(.dtors.*)))
        _fini = .;
    } > APPROM

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > APPSRAM
    PROVIDE_HIDDEN (__exidx_end = .);
}

PROVIDE (_appestack = ORIGIN(APPSRAM) + LENGTH(APPSRAM));
