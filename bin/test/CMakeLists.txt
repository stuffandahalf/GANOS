cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/test C)

include(SetCStdlib)

set(SRCS
	src/main.c
)
set(HEADERS
	
)
add_executable(test ${SRCS} ${HEADERS})
set_c_stdlib(test)

#target_link_options(test PUBLIC -nostdlib -static)

install(TARGETS test DESTINATION bin)
