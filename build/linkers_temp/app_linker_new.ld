INCLUDE linkers/memory_map.ld

SECTIONS
{
    .text :
    {
        _text = .;
        KEEP(*(.isr_vector))

		*(.text.g_pfnVectors)
		*(.text.main)
		*(.text.pui32Stack)
		*(.text.Delay)
		*(.text.IntDefaultHandler)
		*(.text.ResetISR)
		*(.text.zero_loop)
		*(.text.FaultISR)
		*(.text.NmiSR)
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