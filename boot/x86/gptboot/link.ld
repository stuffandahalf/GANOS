/*OUTPUT_FORMAT(binary)*/
/*OUTPUT(gptboot/com)*/

ENTRY(_start)

SECTIONS
{
	. = 0x0100;
	
	.bootloader :
	{
		*(.text .text.*)
		*(.data .data.*)
		*(.rodata .rodata.*)
	}
}
