cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/echo C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(echo ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(echo)
endif()

install(TARGETS echo DESTINATION bin)

