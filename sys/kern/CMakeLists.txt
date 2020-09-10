cmake_minimum_required(VERSION 3.1)
project(ALiX/sys/kern C ASM-ATT)

if(NOT DEFINED ALIX_KERNEL_FORMAT)
	set(ALIX_KERNEL_FORMAT elf)
endif()

set(SRCS
	src/kern_main.c
)

add_executable(alix ${SRCS})

target_compile_options(alix PUBLIC -ffreestanding)# -nostdinc)
set(CMAKE_ASM-ATT_FLAGS "${CMAKE_ASM-ATT_FLAGS} --target=${ALIX_TARGET_TRIPLE}")
target_link_options(alix PUBLIC -nostdlib)# -static)

if(ALIX_KERNEL_FORMAT STREQUAL elf)
	message(DEBUG "Kernel being built as elf application")
	target_link_options(alix PUBLIC -static)
elseif(ALIX_KERNEL_FORMAT STREQUAL efi)
	message(DEBUG "Kernel being built as efi application")
elseif(ALIX_KERNEL_FORMAT STREQUAL multiboot)
	message(DEBUG "Kernel being built as multiboot kernel")
	set(MULTIBOOT_SRCS multiboot/bootstrap.s)
	set(MULTIBOOT_LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/multiboot/link.ld")
	
	target_sources(alix PRIVATE ${MULTIBOOT_SRCS})
	target_link_options(alix PUBLIC -static -T ${MULTIBOOT_LINKER_SCRIPT})
	set_target_properties(alix PROPERTIES LINK_DEPENDS "${MULTIBOOT_LINKER_SCRIPT}")
else()
	message(FATAL_ERROR "ALIX_KERNEL_FORMAT set to unknown value \"${ALIX_KERNEL_FORMAT}\"")
endif()

install(TARGETS alix DESTINATION ${CMAKE_INSTALL_PREFIX})

