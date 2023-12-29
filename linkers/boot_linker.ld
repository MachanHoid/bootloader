INCLUDE linkers/memory_map.ld

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
        *(.text .text* .gnu.linkonce.t.*)
        *(.rodata .rodata* .gnu.linkonce.r.*)
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

PROVIDE (_estack = ORIGIN(SRAM) + LENGTH(SRAM));
