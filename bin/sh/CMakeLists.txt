cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/sh C)

set(SRC
	src/builtins.c
	src/main.c
)
set(HEADERS
	src/builtins.h
)
add_executable(sh ${SRC} ${HEADERS})

install(TARGETS sh DESTINATION bin)

