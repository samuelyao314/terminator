-- 测试：热更新机制
thread = 1
harbor = 0
lualoader = "lualib/loader.lua"
bootstrap = "snlua bootstrap"   -- The service for bootstrap

start = "hotfix"  -- main script

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua;"

snax = "../service/?.lua;../service/?/init.lua;service/?.lua"
luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua"
cpath = "../cservice/?.so;cservice/?.so"

preload="../lualib/bw/preload.lua"
need_hotfix=true  -- 开启热更新
