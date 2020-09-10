cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/uname C)

include(SetCStdlib)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(uname ${SRC} ${HEADERS})
set_c_stdlib(uname)

install(TARGETS uname DESTINATION usr/bin)

