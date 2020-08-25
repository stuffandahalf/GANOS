cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/echo C)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(echo ${SRC} ${HEADERS})

install(TARGETS echo DESTINATION bin)

