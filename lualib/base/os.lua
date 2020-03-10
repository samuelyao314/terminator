--------------------------------------
----- 对标准库 io 的补充
-------------------------------------
local os = os or {}

local lfs = require "lfs"

-- 返回当前工作目录
os.getcwd = function()
    return lfs.currentdir()
end


return os