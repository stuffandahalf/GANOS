cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/make C)

file(GLOB_RECURSE SRC "src/*.c")
file(GLOB_RECURSE INCLUDE "src/*.h")
add_executable(make ${SRC} ${INCLUDE})

install(TARGETS make DESTINATION usr/bin)

