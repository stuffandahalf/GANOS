cmake_minimum_required(VERSION 2.8)
project(ALiX/boot/x86/pmbr ASM-ATT)

set(SRCS src/pmbr.s)
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link.ld")

add_executable(pmbr.bin ${SRCS})
target_compile_options(pmbr.bin PUBLIC "--target=${ALIX_TARGET_TRIPLE}")
#target_link_libraries(pmbr.bin "-Ttext 0x7c00" "--oformat binary")
target_link_libraries(pmbr.bin "-T ${LINKER_SCRIPT}" "--oformat binary")
set_target_properties(pmbr.bin PROPERTIES LINK_DEPENDS "${LINKER_SCRIPT}")

install(TARGETS pmbr.bin DESTINATION boot/x86/)

