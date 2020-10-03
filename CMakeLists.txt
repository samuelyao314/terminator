cmake_minimum_required (VERSION 2.8)
project(terminator C)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "DEBUG")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -ggdb")

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CMAKE_SHARED_LINKER_FLAGS "-undefined dynamic_lookup")
    set(CMAKE_MACOSX_RPATH 0)
endif()

macro (add_lua_library lname)
    add_library(${lname} SHARED ${ARGN})
    set_target_properties(${lname} PROPERTIES PREFIX "")
    set_target_properties(${lname} PROPERTIES SUFFIX ".so")
endmacro()

set(LUA_INCLUDE_DIR  ${PROJECT_SOURCE_DIR}/skynet/3rd/lua)
include_directories (${LUA_INCLUDE_DIR})

# so 文件（Lua C模块）输出目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/luaclib)

add_subdirectory(thirdparty)
add_subdirectory(lualib-src)
