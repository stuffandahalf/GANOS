cmake_minimum_required(VERSION 2.8)
project(ALiX/libexec/ld-elf C)

set(LD_ELF_VERSION_MAJOR 0)
set(LD_ELF_VERSION_MINOR 0)
set(LD_ELF_VERSION_PATCH 1)
set(LD_ELF_VERSION_STRING "${LD_ELF_VERSION_MAJOR}.${LD_ELF_VERSION_MINOR}.${LD_ELF_VERSION_PATCH}")

#include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/include/CheckAndAddType.cmake)

set(SRC
	src/main.c
)
set(PUB_HEADERS
)
#set(UNCONFIGURED_HEADERS include/test.h.in)

add_library(ld-elf SHARED ${SRC})
set_target_properties(ld-elf
	PROPERTIES
		VERSION ${LD_ELF_VERSION_STRING}
		#		SOVERSION ${LD_ELF_VERSION_MAJOR}
		SOVERSION 1
		PREFIX ""
)
#target_include_directories(c 
#	PUBLIC
#		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
#		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
#		$<INSTALL_INTERFACE:usr/include>
#)
target_link_libraries(ld-elf "-nostdlib")

#get_filename_component(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR} NAME)
#foreach(HEADER ${UNCONFIGURED_HEADERS})
#	string(REGEX REPLACE "[.]h[.]in$" ".h" CONFIGURED_HEADER ${HEADER})
#	configure_file(${HEADER} ${CONFIGURED_HEADER} @ONLY)
#	list(APPEND PUB_HEADERS ${BUILD_DIR}/${CONFIGURED_HEADER})
#endforeach()

#set_target_properties(c PROPERTIES PUBLIC_HEADER "${PUB_HEADERS}")

install(TARGETS ld-elf
	DESTINATION libexec
)
#install(DIRECTORY include
#	DESTINATION usr
#	FILES_MATCHING PATTERN "*.h"
#)
#install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
#	DESTINATION usr
#	FILES_MATCHING PATTERN "*.h"
#)

