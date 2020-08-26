cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/echo C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/include/SetCStdlib.cmake)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(echo ${SRC} ${HEADERS})
set_c_stdlib(echo)

install(TARGETS echo DESTINATION bin)

