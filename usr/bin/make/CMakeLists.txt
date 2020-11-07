cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/make C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRCS
	src/main.c
)

add_executable(make ${SRCS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(make)
endif()
target_compile_definitions(make PRIVATE _POSIX_C_SOURCE=200112L)

install(TARGETS make DESTINATION usr/bin)

