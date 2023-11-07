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
    } > BOOTSRAM

    .bss :
    {
        _bootbss = .;
        *(.bss*)
        *(COMMON)
        _bootebss = .;
    } > BOOTSRAM
}

PROVIDE (_bootestack = ORIGIN(BOOTSRAM) + LENGTH(BOOTSRAM));
