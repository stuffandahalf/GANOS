cmake_minimum_required(VERSION 2.8)
project(ALiX)

# ORDER MATTERS
# Build kernel, bootloaders, libraries, then userspace applications

add_subdirectory(lib)
add_subdirectory(libexec)
add_subdirectory(sys)
add_subdirectory(boot)
#add_subdirectory(bin)
#add_subdirectory(usr/bin)

