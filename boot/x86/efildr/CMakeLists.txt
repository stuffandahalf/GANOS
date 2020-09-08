cmake_minimum_required(VERSION 2.8)
project(ALiX/boot/x86/efildr C)

set(SRCS src/efildr.c)

add_executable(efildr ${SRCS})

target_link_libraries(efildr "-nolibc")

if(TARGET efi)
    target_link_libraries(efildr efi)
else()
    message(STATUS "no libefi")
endif()
