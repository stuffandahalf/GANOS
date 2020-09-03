cmake_minimum_required(VERSION 2.8)
project(ALiX/sys/kern C)

file(GLOB SOURCES *.c)

add_executable(alix ${SOURCES})

target_compile_options(alix PUBLIC -ffreestanding -nostdinc)
target_link_options(alix PUBLIC -nostdlib)
#target_link_options(alix PUBLIC -nostdlib -no-dynamic-linker)

install(TARGETS alix DESTINATION ${CMAKE_INSTALL_PREFIX})

