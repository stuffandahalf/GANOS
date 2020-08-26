cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/clear C)

include(${CMAKE_CURRENT_LIST_DIR}/../../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(clear ${SRC} ${HEADERS})
set_c_stdlib(clear)

install(TARGETS clear DESTINATION usr/bin)

