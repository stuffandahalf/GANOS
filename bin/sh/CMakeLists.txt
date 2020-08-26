cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/sh C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/builtins.c
	src/lookup.c
	src/main.c
)
set(HEADERS
	src/builtins.h
	src/lookup.h
)
add_executable(sh ${SRC} ${HEADERS})
set_c_stdlib(sh)

install(TARGETS sh DESTINATION bin)

