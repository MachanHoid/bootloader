INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
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
}

PROVIDE (_appestack = ORIGIN(APPSRAM) + LENGTH(APPSRAM));
