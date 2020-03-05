-- 对内存进行采样
-- 底层的检测原理见 https://www.cnblogs.com/yaukey/p/unity_lua_memory_leak_trace.html

local mri = require "perf/MemoryReferenceInfo"

local _M = {}

-- 打印当前 Lua 虚拟机的所有内存引用快照到文件
--
function _M.dump_snapshot(filename)
    local save_path = './'
    collectgarbage("collect")
    mri.m_cMethods.DumpMemorySnapshot(save_path, filename, -1)
end

return _M
