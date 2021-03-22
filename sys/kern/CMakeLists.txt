cmake_minimum_required(VERSION 3.1)
project(ALiX/sys/kern C ASM-ATT)

if(NOT DEFINED ALIX_KERNEL_FORMAT)
	set(ALIX_KERNEL_FORMAT elf)
endif()

if(NOT DEFINED ALIX_TARGET_PROCESSOR)
	message(DEBUG "\${CMAKE_SYSTEM_PROCESSOR} = \"${CMAKE_SYSTEM_PROCESSOR}\"")
	set(ALIX_TARGET_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
endif()

set(SRCS
	src/kern_main.c
)

add_executable(alix ${SRCS})

target_include_directories(alix PRIVATE include ${CMAKE_CURRENT_BINARY_DIR}/include)
target_compile_options(alix PUBLIC -ffreestanding)# -fno-stack-protector)# -nostdinc)
set(CMAKE_ASM-ATT_FLAGS "${CMAKE_ASM-ATT_FLAGS} --target=${ALIX_TARGET_TRIPLE}")
target_link_options(alix PUBLIC -nostartfiles -nolibc)
#target_link_options(alix PUBLIC -nostdlib)# -static)

if(ALIX_KERNEL_FORMAT STREQUAL elf)
	message(DEBUG "Kernel being built as elf application")
	set(ALIX_KERNEL_FORMAT_ELF 1)
	target_link_options(alix PUBLIC -static)
elseif(ALIX_KERNEL_FORMAT STREQUAL efi)
	message(DEBUG "Kernel being built as efi application")
	set(ALIX_KERNEL_FORMAT_EFI 1)
	set(EFI_SRCS efi/bootstrap.c)
	target_sources(alix PRIVATE ${EFI_SRCS})
	if(TARGET efi)
		target_link_libraries(alix PRIVATE efi)
	endif()
elseif(ALIX_KERNEL_FORMAT STREQUAL multiboot)
	if(ALIX_TARGET_PROCESSOR STREQUAL amd64 OR ALIX_TARGET_PROCESSOR STREQUAL i386)
		message(DEBUG "Kernel being built as multiboot kernel")
	else()
		message(FATAL_ERROR "Multiboot requires an x86 processor")
	endif()
	set(ALIX_KERNEL_FORMAT_MULTIBOOT 1)
	set(MULTIBOOT_SRCS multiboot/bootstrap.s multiboot/setup.c)
	set(MULTIBOOT_LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/multiboot/link.ld")
	
	target_sources(alix PRIVATE ${MULTIBOOT_SRCS})
	target_link_options(alix PUBLIC -static -T ${MULTIBOOT_LINKER_SCRIPT})
	set_target_properties(alix PROPERTIES LINK_DEPENDS "${MULTIBOOT_LINKER_SCRIPT}")
else()
	message(FATAL_ERROR "ALIX_KERNEL_FORMAT set to unknown value \"${ALIX_KERNEL_FORMAT}\"")
endif()

if(ALIX_TARGET_PROCESSOR STREQUAL i386 OR ALIX_TARGET_PROCESSOR STREQUAL amd64)
	target_sources(alix PRIVATE
		src/x86/boot_info.h
		src/x86/early_console.c
		src/x86/init.c
	)
endif()

configure_file(include/platform/info.h.in include/platform/info.h)

install(TARGETS alix DESTINATION ${CMAKE_INSTALL_PREFIX})

