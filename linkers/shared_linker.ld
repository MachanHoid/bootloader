INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _sharedtext = .;
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        _sharedetext = .;
    } > SHARED

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _shareddata = .;
        _sharedldata = LOADADDR (.data);
        *(vtable)
        *(.data*)
        _sharededata = .;
    } > SHAREDSRAM

    .bss :
    {
        _sharedbss = .;
        *(.bss*)
        *(COMMON)
        _sharedebss = .;
    } > SHAREDSRAM
}
