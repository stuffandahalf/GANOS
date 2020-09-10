cmake_minimum_required(VERSION 2.8)
project(ALiX/boot/x86/gptboot ASM-ATT)

set(SRCS src/gptboot.s)
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link.ld")

add_executable(gptboot.com ${SRCS})
target_compile_options(gptboot.com PUBLIC "--target=${ALIX_TARGET_TRIPLE}")
target_link_libraries(gptboot.com "-T ${LINKER_SCRIPT}" "--oformat binary")
set_target_properties(gptboot.com PROPERTIES LINK_DEPENDS "${LINKER_SCRIPT}")

install(TARGETS gptboot.com DESTINATION boot/x86/)
