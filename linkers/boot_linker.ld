INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _boottext = .;
        KEEP(*(.isr_vector))
        *(.text .text* .gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)
        *(.rodata .rodata* .gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)
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

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > BOOTSRAM
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _end = . ;
}

/* end of allocated ram is start of heap, heap grows up towards stack*/
PROVIDE(end = _end);

PROVIDE (_estack = ORIGIN(SRAM) + LENGTH(SRAM));
