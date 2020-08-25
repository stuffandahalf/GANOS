cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/uname C)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(uname ${SRC} ${HEADERS})

install(TARGETS uname DESTINATION usr/bin)

