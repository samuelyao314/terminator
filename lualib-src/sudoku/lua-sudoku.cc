#include <stdio.h>
#include <string>

#include "lua-sudoku.h"
#include "sudoku.h"


static int l_solve(lua_State *L)
{
    const char *p = lua_tostring(L, 1);
    if (!p) {
        lua_pushliteral(L, "argument must be string");
        lua_error(L);
    }

    std::string puzzle = p; 
    std::string result = solveSudoku(p);
    lua_pushstring(L, result.c_str());
    return 1;
}

static const struct luaL_Reg mylib[] = {
    {"solve", l_solve},
    {NULL, NULL},
};



int luaopen_sudoku(lua_State *L)
{
    luaL_newlib(L, mylib);
    return 1;
}
