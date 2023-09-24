INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _text = .;
        KEEP(*(.isr_vector))

		*(.text.main)
		*(.text.IntDefaultHandler)
		*(.text.g_pfnVectors)
		*(.text.ResetISR)
		*(.text.FaultISR)
		*(.text.Delay)
		*(.text.zero_loop)
		*(.text.NmiSR)
		*(.text.pui32Stack)
        *(.rodata*)
        _etext = .;
    } > APPROM 

/DISCARD/ :{
		
	}

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _data = .;
        _ldata = LOADADDR (.data);
        *(vtable)
        *(.data*)
        _edata = .;
    } > SRAM

    .bss :
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > SRAM
}
INCLUDE build/linkers_temp/shared_syms.ld