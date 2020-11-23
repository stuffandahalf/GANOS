cmake_minimum_required(VERSION 3.1)
project(ALiX/bin/sh C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

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
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(sh)
endif()

install(TARGETS sh DESTINATION bin)

