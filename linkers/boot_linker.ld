INCLUDE linkers/memory_map.ld

SECTIONS
{
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
    } > SRAM

    .bss :
    {
        _bootbss = .;
        *(.bss*)
        *(COMMON)
        _bootebss = .;
    } > SRAM
}

PROVIDE (_estack = ORIGIN(SRAM) + LENGTH(SRAM));