cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/pwd C)

include(SetCStdlib)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(pwd ${SRC} ${HEADERS})
set_c_stdlib(pwd)

install(TARGETS pwd DESTINATION usr/bin)

