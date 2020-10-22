-- 聊天服务
thread = 1
harbor = 0
lualoader = "lualib/loader.lua"
bootstrap = "snlua bootstrap"   -- The service for bootstrap

start = "chat"  -- main script

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua;"

snax = "../service/?.lua;../service/?/init.lua;service/?.lua"
luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua"
cpath = "../cservice/?.so;cservice/?.so"

-- 单步调试
logger = "vscdebuglog"
logservice = "snlua"
vscdbg_open = "$vscdbg_open"
vscdbg_bps = [=[$vscdbg_bps]=]