cmake_minimum_required(VERSION 2.8)
enable_language(ASM-ATT)
#enable_language(ASM)
project(ALiX/boot/x86/pmbr ASM-ATT)

file(GLOB_RECURSE SRC "src/*.s")
add_executable(pmbr.bin ${SRC})
target_link_libraries(pmbr.bin "-Ttext 0x7c00" "--oformat binary")

install(TARGETS pmbr.bin DESTINATION boot/x86/)

