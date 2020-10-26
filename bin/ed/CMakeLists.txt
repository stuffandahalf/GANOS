cmake_minimum_required(VERSION 2.8)
project(ALiX/bin/ed C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)
add_executable(ed ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(ed)
endif()

install(TARGETS ed DESTINATION bin)

