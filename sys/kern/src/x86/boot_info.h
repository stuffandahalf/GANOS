#ifndef ALIX_KERNEL_X86_BOOT_INFO_H
#define ALIX_KERNEL_X86_BOOT_INFO_H

#include <platform/info.h>
#if defined(ALIX_KERNEL_FORMAT_MULTIBOOT)
#include <platform/x86/multiboot.h>
extern struct multiboot_info *mb_info;
#elif defined(ALIX_KERNEL_FORMAT_EFI)

#elif defined(ALIX_KERNEL_FORMAT_ELF)

#else
#error Invalid kernel format
#endif /* ALIX_KERNEL_FORMAT */

#endif

