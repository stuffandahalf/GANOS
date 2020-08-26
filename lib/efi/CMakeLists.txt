cmake_minimum_required(VERSION 2.8)
project(ALiX/lib/efi C)

set(PUB_HEADERS
	include/sys/_null.h	
	include/stdio.h
	include/unistd.h
)
set(UNCONFIGURED_HEADERS )

add_library(efi INTERFACE)
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

#install(TARGETS c
#	DESTINATION lib
#)
install(DIRECTORY include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
