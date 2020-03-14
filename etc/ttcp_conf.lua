-- 测试常用的Lua 库
thread = 1
logger = nil
harbor = 0
lualoader = "lualib/loader.lua"
bootstrap = "snlua bootstrap"   -- The service for bootstrap

start = "ttcp"  -- main script

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua;"

snax = "../service/?.lua;../service/?/init.lua;service/?.lua"
luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua"
cpath = "../cservice/?.so;cservice/?.so"