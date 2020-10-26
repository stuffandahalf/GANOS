cmake_minimum_required(VERSION 2.8)
project(ALiX/usr/bin/du C)

include(SetCStdlib OPTIONAL RESULT_VARIABLE HAVE_ALIX_CMAKE_MODULES)

set(SRC
	src/main.c
)
set(HEADERS

)

add_executable(du ${SRC} ${HEADERS})
if(HAVE_ALIX_CMAKE_MODULES)
	set_c_stdlib(du)
endif()

install(TARGETS du DESTINATION usr/bin)

