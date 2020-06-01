cmake_minimum_required(VERSION 2.8)
project(ALiX/usr.bin/pwd C)

file(GLOB_RECURSE SRC "src/*.c")
file(GLOB_RECURSE INCLUDE "src/*.h")
add_executable(pwd ${SRC} ${INCLUDE})

