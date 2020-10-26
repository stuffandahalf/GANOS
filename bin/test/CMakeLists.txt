cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/test C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRCS
	src/main.c
)
set(HEADERS
	
)
add_executable(test ${SRCS} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(test)
endif()

#target_link_options(test PUBLIC -nostdlib -static)

install(TARGETS test DESTINATION bin)
