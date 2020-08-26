cmake_minimum_required(VERSION 2.8)
project(ALiX/lib/libc C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/CheckAndAddType.cmake)

set(UNISTD_SRCS
	unistd/exit.c
)
set(PUB_HEADERS
	include/sys/_null.h	
	include/stdio.h
	include/unistd.h
)
set(UNCONFIGURED_HEADERS include/test.h.in)

add_library(c SHARED ${UNISTD_SRCS})
target_include_directories(c 
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
		$<INSTALL_INTERFACE:usr/include>
)

get_filename_component(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR} NAME)
foreach(HEADER ${UNCONFIGURED_HEADERS})
	string(REGEX REPLACE "[.]h[.]in$" ".h" CONFIGURED_HEADER ${HEADER})
	configure_file(${HEADER} ${CONFIGURED_HEADER} @ONLY)
	list(APPEND PUB_HEADERS ${BUILD_DIR}/${CONFIGURED_HEADER})
endforeach()

#set_target_properties(c PROPERTIES PUBLIC_HEADER "${PUB_HEADERS}")

check_and_add_type(c "char" CHAR YES)
check_and_add_type(c "short int" SHORT_INT YES)
check_and_add_type(c "int" INT YES)
check_and_add_type(c "long int" LONG_INT YES)
check_and_add_type(c "long long int" LONG_LONG_INT YES)
check_and_add_type(c "void *" VOID_PTR YES)

message(STATUS "\${CHAR}=${CHAR}")
message(STATUS "\${SHORT_INT}=${SHORT_INT}")
message(STATUS "\${INT}=${INT}")
message(STATUS "\${LONG_INT}=${LONG_INT}")
message(STATUS "\${LONG_LONG_INT}=${LONG_LONG_INT}")
message(STATUS "\${VOID_PTR}=${VOID_PTR}")

install(TARGETS c
	DESTINATION lib
)
install(DIRECTORY include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
