-- 测试：热更新机制
local skynet = require "skynet"

-- import 加载模块，会支持热更新
local mod = import("mod")

local function print_info()
    -- 如果发送热更新， 打印的结果不一样. 这里模拟了使用场景
    mod.func()
    skynet.timeout(500,  print_info)
end

skynet.start(function()
    skynet.newservice("debug_console",8000)
    skynet.error("start to test hotfix...")

    -- 10秒 触发定时器
    skynet.timeout(500,  print_info)   --
end)
