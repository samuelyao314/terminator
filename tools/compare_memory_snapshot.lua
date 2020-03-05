-- 分析比较出内存文件中新增加的对象
-- 生成内存镜像，细节见 examples/service/perf
-- 底层的检测原理见 https://www.cnblogs.com/yaukey/p/unity_lua_memory_leak_trace.html
package.path = '../lualib/?.lua;' .. package.path

local mri = require('perf/MemoryReferenceInfo')

-- 先, 生成的内存镜像文件
local before_file = arg[1]
-- 后, 生成的内存镜像文件
local after_file = arg[2]

mri.m_cMethods.DumpMemorySnapshotComparedFile('./', "Compared", -1, before_file, after_file)
