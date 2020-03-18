cmake_minimum_required (VERSION 2.8)
project(luaset)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CMAKE_SHARED_LINKER_FLAGS "-undefined dynamic_lookup")
    set(CMAKE_MACOSX_RPATH 0)
endif()

if(WIN32)
	set(suffix ".dll")
    add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB -DHTTP_PARSER_STRICT=0)
else()
	set(suffix ".so")
endif()

macro (add_lua_library lname)
    add_library(${lname} SHARED ${ARGN})
    set_target_properties(${lname} PROPERTIES PREFIX "")
    set_target_properties(${lname} PROPERTIES SUFFIX ${suffix})
endmacro()

set(CMAKE_CXX_FLAGS_DEBUG "-O0 -Wall -g")
set(CMAKE_C_FLAGS_DEBUG "-O0 -Wall -g")

set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG -Wall -g")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG -Wall -g")

set(LUA_INCLUDE_DIR  ${PROJECT_SOURCE_DIR}/skynet/3rd/lua)
include_directories (${LUA_INCLUDE_DIR})

set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/luaclib)

add_subdirectory(thirdparty)
add_subdirectory(lualib-src)
