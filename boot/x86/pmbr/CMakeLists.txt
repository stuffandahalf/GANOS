cmake_minimum_required(VERSION 2.8)
#project(ALiX/boot/x86/pmbr ASM-ATT)
#project(ALiX/boot/x86/pmbr C)
project(ALiX/boot/x86/pmbr ASM-ATT)

file(GLOB_RECURSE SRC "src/*.s")
add_executable(pmbr.bin ${SRC})
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link.ld")
#target_compile_options(pmbr.bin PUBLIC "-c" "--target=${ALIX_TARGET_TRIPLE}")
target_compile_options(pmbr.bin PUBLIC "--target=${ALIX_TARGET_TRIPLE}")
#target_link_libraries(pmbr.bin "-Ttext 0x7c00" "--oformat binary")
#target_link_libraries(pmbr.bin "--target=${ALIX_TARGET_TRIPLE}" "-T ${LINKER_SCRIPT}" "-ffreestanding" "-nostdlib")
target_link_libraries(pmbr.bin "-T ${LINKER_SCRIPT}" "--oformat binary")
#set_target_properties(pmbr.bin
#	PROPERTIES
#LINK_DEPENDS "${LINKER_SCRIPT}"
		#		LINKER_LANGUAGE C
		#)

install(TARGETS pmbr.bin DESTINATION boot/x86/)

