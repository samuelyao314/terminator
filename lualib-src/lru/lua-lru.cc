#include "lru.h"
#include "lua.hpp"
#include <string>
#include <string.h>
#include <assert.h>

#define LUA_LRU_MT_INT_MAP          ("hive-framework.lruMT.int.map")
#define LUA_LRU_MT_INT_HASHMAP      ("hive-framework.lruMT.int.hashmap")
#define LUA_LRU_MT_STRING_MAP       ("hive-framework.lruMT.string.map")
#define LUA_LRU_MT_STRING_HASHMAP   ("hive-framework.lruMT.string.hashmap")

#define LUA_LRU_CORE                ("__lru__")
#define LUA_LRU_DATA                ("__data__")
#define lru_t                       lru<T, MapT>

template<typename T, template<typename...> class MapT>
static int lua_tolru(lua_State* L, int idx, lru_t** ret_container, int* ret_data_idx) {
    if (!lua_istable(L, idx))
        return false;

    lua_getfield(L, idx, LUA_LRU_CORE);
    lru_t* container = (lru_t*)lua_touserdata(L, -1);
    if (!container)
        return false;

    lua_getfield(L, 1, LUA_LRU_DATA);
    if (!lua_istable(L, -1))
        return false;

    *ret_container = container;
    *ret_data_idx = lua_gettop(L);
    return true;
}

static int lru_tokey(lua_State* L, int idx, int64_t* key) {
    if (!lua_isinteger(L, idx))
        return false;
    *key = lua_tointeger(L, idx);
    return true;
}

static int lru_tokey(lua_State* L, int idx, std::string* key) {
    if (!lua_isstring(L, idx))
        return false;
    *key = lua_tostring(L, idx);
    return true;
}

static void lru_pushkey(lua_State* L, const int64_t& key) {
    lua_pushinteger(L, key);
}

static void lru_pushkey(lua_State* L, const std::string& key) {
    lua_pushstring(L, key.c_str());
}

template<typename T, template<typename...> class MapT>
static int lru_gc(lua_State* L) {
    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    delete container;
    return 0;
}

template<typename T, template<typename...> class MapT>
static int lru_set(lua_State* L) {
    T key;
    if (!lru_tokey(L, 2, &key))
        return luaL_argerror(L, 2, "invalid argument type");

    if (lua_isnil(L, 3))
        return luaL_argerror(L, 2, "value cannot be nil");

    int discard_callback_exist = lua_isfunction(L, 4);

    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    int index;
    if (!discard_callback_exist) {
        index = container->set(key, nullptr);
        assert(index > 0);
    } else {
        index = container->set(key, [L, data_idx](int discard_index, const T& discard_key){
            lua_pushvalue(L, 4);
            lru_pushkey(L, discard_key);
            lua_rawgeti(L, data_idx, discard_index);
            lua_pcall(L, 2, 0, 0);
        });
        assert(index > 0);
    }

    lua_pushvalue(L, 3);
    lua_rawseti(L, data_idx, index);
    return 0;
}

template<typename T, template<typename...> class MapT>
static int lru_del(lua_State* L) {
    T key;
    if (!lru_tokey(L, 2, &key))
        return luaL_argerror(L, 2, "invalid argument type");

    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    int index = container->del(key);
    if (index > 0) {
        lua_pushnil(L);
        lua_rawseti(L, data_idx, index);
    }
    return 0;
}

template<typename T, template<typename...> class MapT>
static int lru_get(lua_State* L) {
    T key;
    if (!lru_tokey(L, 2, &key))
        return luaL_argerror(L, 1, "invalid argument type");

    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    int index = container->get(key);
    if (index == 0)
        return 0;

    lua_rawgeti(L, data_idx, index);
    return 1;
}

template<typename T, template<typename...> class MapT>
static int lru_count(lua_State* L) {
    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    int count = container->count();
    lua_pushinteger(L, count);
    return 1;
}

template<typename T, template<typename...> class MapT>
static int lru_next(lua_State* L) {
    int key_isnil = lua_isnil(L, 2);
    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    int index = 0;
    T key;
    if (key_isnil) {
        index = container->first(key);
    } else {
        if (!lru_tokey(L, 2, &key))
            return luaL_argerror(L, 1, "invalid argument type");
        index = container->next(key);
    }

    if (index == 0)
        return 0;

    lru_pushkey(L, key);
    lua_rawgeti(L, data_idx, index);
    return 2;
}

template<typename T, template<typename...> class MapT>
static int lru_pairs(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_pushcclosure(L, lru_next<T, MapT>, 0);
    lua_pushvalue(L, 1);
    lua_pushnil(L);
    return 3;
}

template<typename T, template<typename...> class MapT>
static int lru_resize(lua_State* L) {
    int size = (int)lua_tointeger(L, 2);
    if (size <= 0)
        return luaL_argerror(L, 1, "expect size > 0");

    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    std::vector<int> remove_list;
    container->resize(remove_list, size);

    for (auto& index : remove_list) {
        lua_pushnil(L);
        lua_rawseti(L, data_idx, index);
    }
    return 2;
}

template<typename T, template<typename...> class MapT>
static int lru_clear(lua_State* L) {
    lru_t* container = nullptr;
    int data_idx = 0;
    if (!lua_tolru(L, 1, &container, &data_idx))
        return luaL_argerror(L, 1, "expect lru object");

    container->clear();

    lua_pushnil(L);
    while (lua_next(L, data_idx)) {
        int index = (int)lua_tointeger(L, -2);
        lua_pushnil(L);
        lua_rawseti(L, data_idx, index);
        lua_pop(L, 1);
    }
    return 0;
}

static int create_lru_container(lua_State* L, int type_idx, int map_idx, int size, void** container, const char** tname) {
    const char* type = lua_tostring(L, type_idx);
    const char* map = lua_tostring(L, map_idx);
    if (!map)
        map = "map";

    if (strcmp(type, "integer") == 0 && strcmp(map, "map") == 0) {
        *container = new lru<int64_t, std::map>(size);
        *tname = LUA_LRU_MT_INT_MAP;
        return true;
    }

    if (strcmp(type, "integer") == 0 && strcmp(map, "hashmap") == 0) {
        *container = new lru<int64_t, std::unordered_map>(size);
        *tname = LUA_LRU_MT_INT_HASHMAP;
        return true;
    }

    if (strcmp(type, "string") == 0 && strcmp(map, "map") == 0) {
        *container = new lru<std::string, std::map>(size);
        *tname = LUA_LRU_MT_STRING_MAP;
        return true;
    }

    if (strcmp(type, "string") == 0 && strcmp(map, "hashmap") == 0) {
        *container = new lru<std::string, std::unordered_map>(size);
        *tname = LUA_LRU_MT_STRING_HASHMAP;
        return true;
    }

    return false;
}

static int new_lru(lua_State* L) {
    int size = (int)lua_tointeger(L, 1);
    if (size <= 0)
        return luaL_argerror(L, 1, "expect size > 0");

    void* container = nullptr;
    const char* tname = nullptr;

    if (!create_lru_container(L, 2, 3, size, &container, &tname))
        return luaL_argerror(L, 2, "parameter invalid");

    lua_newtable(L);

    lua_createtable(L, size, 0);
    lua_setfield(L, -2, LUA_LRU_DATA);

    lua_pushlightuserdata(L, container);
    lua_setfield(L, -2, LUA_LRU_CORE);

    luaL_getmetatable(L, tname);
    lua_setmetatable(L, -2);

    return 1;
}

template<typename T, template<typename...> class MapT>
static int lru_newmetatable(lua_State* L, const char* tname) {
    if (!luaL_newmetatable(L, tname))
        return false;

    luaL_Reg l[] = {
        { "__gc", lru_gc<T, MapT> },
        { "__len", lru_count<T, MapT> },
        { "__pairs", lru_pairs<T, MapT> },
        { "get", lru_get<T, MapT> },
        { "set", lru_set<T, MapT> },
        { "del", lru_del<T, MapT> },
        { "count", lru_count<T, MapT> },
        { "next", lru_next<T, MapT> },
        { "resize", lru_resize<T, MapT> },
        { "clear", lru_clear<T, MapT> },

        { NULL, NULL },
    };

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, l, 0);
    lua_pop(L, 1);

    return true;
}

extern "C" int luaopen_lru(lua_State* L) {
    luaL_checkversion(L);

    lru_newmetatable<int64_t, std::map>(L, LUA_LRU_MT_INT_MAP);
    lru_newmetatable<int64_t, std::unordered_map>(L, LUA_LRU_MT_INT_HASHMAP);
    lru_newmetatable<std::string, std::map>(L, LUA_LRU_MT_STRING_MAP);
    lru_newmetatable<std::string, std::unordered_map>(L, LUA_LRU_MT_STRING_HASHMAP);

    luaL_Reg l[] = {
        { "new", new_lru },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}




