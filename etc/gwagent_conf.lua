-- gate/watchdog/agent三剑客
thread = 1     -- 启动多少个线程
harbor = 0     -- 单节点
lualoader = "lualib/loader.lua"   -- 不建议修改
bootstrap = "snlua bootstrap"   -- 不建议修改

start = "gwagent"  -- 入口脚本

-- 日志配置，默认打印到标准输出
logservice = "logger"
logger = nil

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua;"

snax = "../service/?.lua;../service/?/init.lua;service/?.lua"
luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua;examples/?.lua"
cpath = "../cservice/?.so;cservice/?.so"
