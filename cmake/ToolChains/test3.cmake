set(CMAKE_SYSTEM_NAME ALiX)

set(ALIX_TARGET_PROCESSOR i386)
#set(ALIX_TARGET_PROCESSOR powerpc)
set(ALIX_TARGET_PROCESSOR_SUBVERSION "")
set(ALIX_TARGET_PLATFORM unknown)
set(ALIX_TARGET_OS alix)
set(ALIX_TARGET_ABI elf)

set(CMAKE_SYSTEM_PROCESSOR ${ALIX_TARGET_PROCESSOR})
set(ALIX_TARGET_TRIPLE "${ALIX_TARGET_PROCESSOR}${ALIX_TARGET_PROCESSOR_SUBVERSION}-${ALIX_TARGET_PLATFORM}-${ALIX_TARGET_OS}-${ALIX_TARGET_ABI}")

get_filename_component(PROJECT_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
set(TOOLS ${PROJECT_ROOT}/tools)
set(CMAKE_SYSROOT ${TOOLS}/llvm)
set(CMAKE_MODULE_PATH ${PROJECT_ROOT}/cmake/Modules;${CMAKE_MODULE_PATH})

set(CMAKE_LINKER ${CMAKE_SYSROOT}/bin/ld.lld)

set(CMAKE_C_COMPILER ${CMAKE_SYSROOT}/bin/clang)
set(CMAKE_C_COMPILER_TARGET ${ALIX_TARGET_TRIPLE})

set(CMAKE_CXX_COMPILER ${CMAKE_SYSROOT}/bin/clang++)
set(CMAKE_CXX_COMPILER_TARGET ${ALIX_TARGET_TRIPLE})

set(CMAKE_ASM-ATT_COMPILER ${CMAKE_SYSROOT}/bin/clang)
if(NOT DEFINED ALIX_ASM-ATT_FLAGS)
	set(ALIX_ASM-ATT_FLAGS "--sysroot=${CMAKE_SYSROOT} -c")
	set(CMAKE_ASM-ATT_FLAGS "${CMAKE_ASM-ATT_FLAGS} ${ALIX_ASM-ATT_FLAGS}")
endif()

#set(CMAKE_ASM-ATT_LINK_EXECUTABLE "<CMAKE_ASM-ATT_COMPILER> <CMAKE_ASM-ATT_LINK_FLAGS> <FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

set(CMAKE_ASM-ATT_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM-ATT_LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN ${TOOLS}/llvm/bin)
#set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN ${TOOLS}/llvm)

#if(NOT DEFINED ALIX_CMAKE_BIN_INIT)
#include_directories(${PROJECT_ROOT}/include)
#	add_library(c SHARED IMPORTED GLOBAL)
#	set(ALIX_CMAKE_BIN_INIT YES)
#endif()
