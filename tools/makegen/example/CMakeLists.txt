cmake_minimum_required(VERSION 3.1)

project(test C)

file(GLOB SRC src/*.c)
file(GLOB HEADERS src/*.h)

add_executable(test ${SRC} ${HEADERS})

