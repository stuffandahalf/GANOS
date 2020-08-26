cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/test C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/includes/SetCStdlib.cmake)

message(STATUS "Linker is ${CMAKE_LINKER}")

set(SRC
	src/main.c
)
set(HEADERS
	
)
add_executable(test ${SRC} ${HEADERS})
#add_library(test STATIC ${SRC} ${INCLUDE})
set_c_stdlib(test)

#install(TARGETS test DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

