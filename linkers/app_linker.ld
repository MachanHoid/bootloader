INCLUDE linkers/memory_map.ld

SECTIONS
{
    .init_array :
    {
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(SORT_BY_INIT_PRIORITY(.ctors.*)))
    } > APPROM

    .text :
    {
        _apptext = .;
        KEEP(*(.isr_vector))
        *(.text .text* .gnu.linkonce.t.*)
        *(.rodata .rodata* .gnu.linkonce.r.*)
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
}

PROVIDE (_estack = ORIGIN(SRAM) + LENGTH(SRAM));
