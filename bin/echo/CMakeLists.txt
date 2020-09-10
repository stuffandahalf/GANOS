cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/echo C)

include(SetCStdlib)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(echo ${SRC} ${HEADERS})
set_c_stdlib(echo)

install(TARGETS echo DESTINATION bin)

