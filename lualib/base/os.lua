--------------------------------------
----- 对标准库 io 的补充
-------------------------------------
local os = os or {}

local lfs = require "lfs"

-- 返回当前工作目录
os.getcwd = function()
    return lfs.currentdir()
end


--
--  Time when data was last modified.
--
function os.get_file_mtime(path)
    local file_time, err = lfs.attributes (path, "modification")
    return file_time, err
end

--
-- get file size (bytes)
--
function os.get_file_size(path)
    local size, err = lfs.attributes(path, "size")
    return size, err
end

return os