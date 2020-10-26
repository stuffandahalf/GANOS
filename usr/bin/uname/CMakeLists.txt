cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/uname C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(uname ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(uname)
endif()

install(TARGETS uname DESTINATION usr/bin)

