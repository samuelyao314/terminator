thread = 1
harbor = 0
lualoader = "lualib/loader.lua"
bootstrap = "snlua bootstrap"   -- The service for bootstrap

start = "sudoku"  -- main script

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua"

luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua"
snax = luaservice
cpath = "../cservice/?.so;cservice/?.so"