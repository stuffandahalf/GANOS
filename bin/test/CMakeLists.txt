cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/test C)

message(STATUS "Linker is ${CMAKE_LINKER}")

file(GLOB_RECURSE SRC "src/*.c")
file(GLOB_RECURSE INCLUDE "src/*.h")
add_executable(test ${SRC} ${INCLUDE})
#add_library(test STATIC ${SRC} ${INCLUDE})

#install(TARGETS test DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

