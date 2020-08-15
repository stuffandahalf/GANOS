cmake_minimum_required(VERSION 2.8)
project(ALiX/lib/libc C)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/CheckAndAddType.cmake)

file(GLOB_RECURSE UNISTD_SRCS unistd/*.c)

add_library(c SHARED ${UNISTD_SRCS})

check_and_add_type(c "char" CHAR YES)
check_and_add_type(c "short int" SHORT_INT YES)
check_and_add_type(c "int" INT YES)
check_and_add_type(c "long int" LONG_INT YES)
check_and_add_type(c "long long int" LONG_LONG_INT YES)
check_and_add_type(c "void *" VOID_PTR YES)

message(STATUS "\${CHAR}=${CHAR}")
message(STATUS "\${SHORT_INT}=${SHORT_INT}")
message(STATUS "\${INT}=${INT}")
message(STATUS "\${LONG_INT}=${LONG_INT}")
message(STATUS "\${LONG_LONG_INT}=${LONG_LONG_INT}")
message(STATUS "\${VOID_PTR}=${VOID_PTR}")

install(TARGETS c DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

