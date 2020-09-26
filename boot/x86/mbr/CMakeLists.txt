cmake_minimum_required(VERSION 2.8)
project(ALiX/boot/x86/mbr ASM-ATT)

set(SRCS src/mbr.s)
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link.ld")

add_executable(mbr.bin ${SRCS})
target_compile_options(mbr.bin PUBLIC "--target=${ALIX_TARGET_TRIPLE}")
target_link_libraries(mbr.bin "-T ${LINKER_SCRIPT}" "--oformat binary")
set_target_properties(mbr.bin PROPERTIES LINK_DEPENDS "${LINKER_SCRIPT}")

install(TARGETS mbr.bin DESTINATION boot/x86/)

