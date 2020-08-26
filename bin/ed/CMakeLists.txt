cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/ed C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(ed ${SRC} ${HEADERS})
set_c_stdlib(ed)

install(TARGETS ed DESTINATION bin)

