INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _apptext = .;
        KEEP(*(.isr_vector))
        *(.text*)
        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        *(.rodata*)
        _appetext = .;
    } > APPROM 

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _appdata = .;
        _appldata = LOADADDR (.data);
        *(vtable)
        *(.data*)
        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        _appedata = .;
    } > APPSRAM

    .bss :
    {
        _appbss = .;
        *(.bss*)
        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        *(COMMON)
        _appebss = .;
    } > APPSRAM
}

PROVIDE (_appestack = ORIGIN(APPSRAM) + LENGTH(APPSRAM));
