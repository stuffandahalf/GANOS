cmake_minimum_required(VERSION 2.8)
project(ALiX/lib/efi C)

set(UNCONFIGURED_HEADERS )

add_library(efi INTERFACE)
target_include_directories(efi
	INTERFACE
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

install(DIRECTORY include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
	DESTINATION usr
	FILES_MATCHING PATTERN "*.h"
)
