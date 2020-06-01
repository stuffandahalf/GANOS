cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/echo C)

file(GLOB_RECURSE SRC "src/*.c")
file(GLOB_RECURSE INCLUDE "src/*.h")
add_executable(echo ${SRC} ${INCLUDE})

install(TARGETS echo DESTINATION bin)

