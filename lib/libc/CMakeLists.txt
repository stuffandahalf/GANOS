cmake_minimum_required(VERSION 2.8)
project(ALiX/lib/libc C)

file(GLOB_RECURSE UNISTD_SRCS unistd/*.c)

add_library(c SHARED ${UNISTD_SRCS})

