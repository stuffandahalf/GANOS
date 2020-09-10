cmake_minimum_required(VERSION 2.8)
project(ALiX/boot)

if(${ALIX_TARGET_PROCESSOR} MATCHES "(i386|amd64)")
	add_subdirectory(x86)
else()
	add_subdirectory(${ALIX_TARGET_PROCESSOR})
endif()

#add_subdirectory(powerpc)
#add_subdirectory(x86)

