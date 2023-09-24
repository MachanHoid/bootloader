INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _text = .;
        KEEP(*(.isr_vector))

		*(.text.FaultISR)
		*(.text.IntDefaultHandler)
		*(.text.NmiSR)
		*(.text.zero_loop)
		*(.text.ResetISR)
		*(.text.g_pfnVectors)
		*(.text.Delay)
		*(.text.main)
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