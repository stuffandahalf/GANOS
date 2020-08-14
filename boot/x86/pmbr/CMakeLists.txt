cmake_minimum_required(VERSION 2.8)
enable_language(ASM-ATT)
project(ALiX/boot/i386/pmbr ASM-ATT)

set(ALIX_TARGET_PROCESSOR i386)
message(STATUS ${ALIX_TARGET_TRIPLE})

file(GLOB_RECURSE SRC "src/*.s")
add_executable(pmbr.bin ${SRC})
#add_link_options(LINKER:-Ttext 0x7c00,--oformat binary)
target_link_options(pmbr.bin PRIVATE SHELL:-Ttext 0x7c00,--oformat binary)

install(TARGETS pmbr.bin DESTINATION boot/x86/)

