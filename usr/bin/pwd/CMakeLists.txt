cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/pwd C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(pwd ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(pwd)
endif()

install(TARGETS pwd DESTINATION usr/bin)

