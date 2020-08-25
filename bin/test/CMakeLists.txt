cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/test C)

message(STATUS "Linker is ${CMAKE_LINKER}")

set(SRC
	src/main.c
)
set(HEADERS
	
)
add_executable(test ${SRC} ${HEADERS})
#add_library(test STATIC ${SRC} ${INCLUDE})

#install(TARGETS test DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

