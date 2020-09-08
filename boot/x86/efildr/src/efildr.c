#include <EFI/efi.h>
//#include <efilib.h>

EFI_STATUS
//EFIAPI
efi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable)
{
	InitializeLib(ImageHandle, SystemTable);
	Print("Hello World!\n");
	return EFI_STATUS;
}

