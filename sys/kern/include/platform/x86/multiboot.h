/* multiboot.h - Multiboot header file
 *
 * SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2020 Gregory Norton
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef ALIX_KERNEL_PLATFORM_X86_MULTIBOOT_H
#define ALIX_KERNEL_PLATFORM_X86_MULTIBOOT_H	1

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/* How many bytes from the start of the file we search for the header. */
#define MULTIBOOT_SEARCH                        8192
#define MULTIBOOT_HEADER_ALIGN                  4

#define MULTIBOOT_HEADER_MAGIC		0x1BADB002
#define MULTIBOOT_BOOTLOADER_MAGIC	0x2BAD002

struct multiboot_header {
	uint32_t magic;
	uint32_t flags;
	uint32_t checksum;

	/* Only valid if MULTIBOOT_AOUT_KLUDGE set */
	uint32_t header_addr;
	uint32_t load_addr;
	uint32_t load_end_addr;
	uint32_t bss_end_addr;
	uint32_t entry_addr;

	/* These are only valid if MULTIBOOT_VIDEO_MODE is set. */
	uint32_t mode_type;
	uint32_t width;
	uint32_t height;
	uint32_t depth;
};

/* The symbol table for a.out. */
struct multiboot_aout_symbol_table {
	uint32_t tabsize;
	uint32_t strsize;
	uint32_t addr;
	uint32_t reserved;
};

struct multiboot_elf_section_header_table {
	uint32_t tabsize;
	uint32_t strsize;
	uint32_t addr;
	uint32_t reserved;
};

#define MULTIBOOT_INFO_MEM_FLAG					(1 << 0)
#define MULTIBOOT_INFO_BOOT_DEV_FLAG			(1 << 1)
#define MULTIBOOT_INFO_CMDLINE_FLAG				(1 << 2)
#define MULTIBOOT_INFO_MODULES_FLAG				(1 << 3)
#define MULTIBOOT_INFO_A_OUT_SYMBOLS_FLAG		(1 << 4)
#define MULTIBOOT_INFO_ELF_SECTION_HEADER_FLAG	(1 << 5)
#define MULTIBOOT_INFO_MEMORY_MAP_FLAG			(1 << 6)
#define MULTIBOOT_INFO_DRIVES_FLAG				(1 << 7)
#define MULTIBOOT_INFO_CONFIG_TABLE_FLAG		(1 << 8)
#define MULTIBOOT_INFO_BOOT_LOADER_NAME_FLAG	(1 << 9)
#define MULTIBOOT_INFO_APM_TABLE_FLAG			(1 << 10)
#define MULTIBOOT_INFO_VBE_TABLE_FLAG			(1 << 11)
#define MULTIBOOT_INFO_FRAMEBUFFER_TABLE_FLAG	(1 << 12)

struct multiboot_info {
	uint32_t flags;
	
	uint32_t mem_lower;
	uint32_t mem_upper;
	
	uint32_t boot_device;
	
	uint32_t cmdline;
	
	uint32_t mods_count;
	uint32_t mods_addr;

	union {
		struct multiboot_aout_symbol_table aout_sym;
		struct multiboot_elf_section_header_table elf_sec;
	} u;
	
	uint32_t mmap_length;
	uint32_t mmap_addr;
	
	uint32_t drives_length;
	uint32_t drives_addr;
	
	uint32_t config_table;
	
	uint32_t boot_loader_name;
	
	uint32_t apm_table;

	uint32_t vbe_control_info;
	uint32_t vbe_mode_info;
	uint16_t vbe_mode;
	uint16_t vbe_interface_seg;
	uint16_t vbe_interface_off;
	uint16_t vbe_interface_len;

	uint64_t framebuffer_addr;
	uint32_t framebuffer_pitch;
	uint32_t framebuffer_width;
	uint32_t framebuffer_height;
	uint8_t framebuffer_bpp;
	uint8_t framebuffer_type;

	union {
		struct {
			uint32_t framebuffer_palette_addr;
			uint16_t framebuffer_palette_num_colors;
		};
		struct {
			uint8_t framebuffer_red_field_position;
			uint8_t framebuffer_red_mask_size;
			uint8_t framebuffer_green_field_position;
			uint8_t framebuffer_green_mask_size;
			uint8_t framebuffer_blue_field_position;
			uint8_t framebuffer_blue_mask_size;
		};
	} color_info;
};

#endif

