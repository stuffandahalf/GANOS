/*OUTPUT_FORMAT(binary)*/
/*OUTPUT(pmbr.bin)*/

ENTRY(_start)

SECTIONS
{
	. = 0x7c00;
	
	.bootloader :
	{
		*(.text .text.*)
		*(.data .data.*)
		*(.rodata .rodata.*)
	}

	. = 0x7e00;
	sector_buffer = .;
}
