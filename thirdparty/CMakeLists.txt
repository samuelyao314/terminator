set(LUA_3RD_PATH ${PROJECT_SOURCE_DIR}/lualib/3rd/)

# https://github.com/xjdrew/lua-zset
aux_source_directory(lua-zset/ SRC_SKIPLIST)
add_lua_library(skiplist ${SRC_SKIPLIST})
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lua-zset/zset.lua
     DESTINATION ${LUA_3RD_PATH})

# https://github.com/openresty/lua-cjson/
set(SRC_CJSON lua-cjson/lua_cjson.c lua-cjson/strbuf.c lua-cjson/fpconv.c)
add_lua_library(cjson ${SRC_CJSON})

# https://github.com/samuelyao314/lua-cmsgpack
aux_source_directory(lua-cmsgpack/ SRC_MSGPACK)
add_lua_library(cmsgpack ${SRC_MSGPACK})

# https://github.com/keplerproject/luafilesystem/
aux_source_directory(luafilesystem/src SRC_LFS)
add_lua_library(lfs ${SRC_LFS})

# https://github.com/starwing/lua-protobuf/
aux_source_directory(lua-protobuf/ SRC_PB)
add_lua_library(pb ${SRC_PB})
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lua-protobuf/protoc.lua
        DESTINATION ${LUA_3RD_PATH})

# https://github.com/jinq0123/hotfix
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/hotfix/lua/hotfix
        DESTINATION ${LUA_3RD_PATH})