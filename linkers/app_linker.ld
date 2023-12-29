INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _apptext = .;
        KEEP(*(.isr_vector))
        *(.text .text* .gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)
        *(.rodata .rodata* .gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)
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

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > APPSRAM
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _end = . ;
}

/* end of allocated ram is start of heap, heap grows up towards stack*/
PROVIDE(end = _end);

PROVIDE (_estack = ORIGIN(SRAM) + LENGTH(SRAM));
