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
    .text :
    {
        . = ALIGN(4);
        _apptext = .;
        KEEP(*(.isr_vector))
        *(.text .text* .gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)
        *(.rodata .rodata* .gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)

        . = ALIGN(4);
        KEEP(*(.init))
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(SORT(.preinit_array*)))
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        . = ALIGN(4);
        _appetext = .;
    } > APPROM

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        
        . = ALIGN(4);
        _appdata = .;
        _appldata = LOADADDR (.data);
        *(vtable)
        *(.data .data* .gnu.linkonce.d.*)
        _appedata = .;
    } > APPSRAM

    .bss (NOLOAD):
    {

        . = ALIGN(4);
        _appbss = .; 
        *(.bss .bss*) 
        *(COMMON)
        . = ALIGN(4); 
        _appebss = .;
        . = ALIGN(8);
    } > APPSRAM 

/*
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        _stack = .;
        . = . + STACK_SIZE;
        . = ALIGN(8);
        _estack = .;
    } > APPSRAM
*/

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > APPSRAM
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _end = . ;
}

PROVIDE (_appestack = ORIGIN(APPSRAM) + LENGTH(APPSRAM));
