cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/make C)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(make ${SRC} ${HEADERS})

install(TARGETS make DESTINATION usr/bin)

