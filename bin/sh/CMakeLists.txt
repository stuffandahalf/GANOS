cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/sh C)

file(GLOB_RECURSE SRC "src/*.c")
file(GLOB_RECURSE INCLUDE "src/*.h")
add_executable(sh ${SRC} ${INCLUDE})

