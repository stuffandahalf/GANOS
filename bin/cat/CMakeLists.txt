cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/cat C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(cat ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(cat)
endif()

install(TARGETS cat DESTINATION bin)

