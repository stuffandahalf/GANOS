cmake_minimum_required(VERSION 3.1)
project(lib/libxnet C)

add_library(xnet
	src/arpa/inet.c
	src/netdb.c
	src/sys/socket.c
)

install(TARGETS xnet DESTINATION lib)
install(DIRECTORY include DESTINATION usr FILES_MATCHING PATTERN "*.h")
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
	DESTINATION usr FILES_MATCHING PATTERN "*.h")

