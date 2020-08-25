cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/pwd C)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(pwd ${SRC} ${HEADERS})

install(TARGETS pwd DESTINATION usr/bin)

