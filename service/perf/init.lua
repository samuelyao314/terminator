local skynet = require "skynet"
local memory = require "perf/memory"

local handler = {}

function handler.dump_memory()
    local address = skynet.address(skynet.self())
    local filename = 'simulate_memory' .. address
    memory.dump_snapshot(filename)
    skynet.error('succ to dump memory snapshot')
end


local function simulate_use_memory()
    local author = {
        Name = "yaukeywang",
        Job = "Game Developer",
        Hobby = "Game, Travel, Gym",
        City = "Beijing",
        Country = "China",
        Ask = function (question)
                return "My answer is for your question: " .. question .. "."
        end
    }

    handler.Author = author
end

skynet.dispatch("lua", function(_,_, cmd, ...)
    skynet.error("cmd", cmd)
    skynet.error("arg", ...)
    local f = assert(handler[cmd])
    skynet.retpack(f(...))
end)


skynet.start(function()
    skynet.newservice("debug_console", 8000)
    skynet.error("Be water my friend.")
    skynet.error("simulate memory leak.")

    -- 当前服务的名称
    -- 先导出一份内存镜像
    handler.dump_memory()
    -- 模拟: 使用了一些对象, 无法回收，处于内存泄漏
    simulate_use_memory()

    -- 用debug_conole，触发再次导出内存镜像
    -- $ telnet 127.0.0.1 8000
    -- 输入以下内容
    -- call 8 "dump_memory",1,2
end)
