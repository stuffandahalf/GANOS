cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/make C)

include(${CMAKE_CURRENT_LIST_DIR}/../../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(make ${SRC} ${HEADERS})
set_c_stdlib(make)

install(TARGETS make DESTINATION usr/bin)

