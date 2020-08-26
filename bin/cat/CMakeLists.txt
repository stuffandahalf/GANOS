cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/cat C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(cat ${SRC} ${HEADERS})
set_c_stdlib(cat)

install(TARGETS cat DESTINATION bin)

