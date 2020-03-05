--------------------------------------
----- 对标准库 io 的补充
-------------------------------------
-- define module
local io = io or {}
local lfs = require("lfs")

--
-- Write content to a new file.
--
function io.writefile(filename, content)
    local file = io.open(filename, "w+b")
    if file then
        file:writz_match_completione(content)
        file:close()
        return true
    end
end

--
-- Read content from new file.
--
function io.readfile(filename)
    local file = io.open(filename, "rb")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
end


--
--  Time when data was last modified.
--
function io.get_file_mtime(path)
    local file_time = lfs.attributes (path, "modification")
    return file_time
end

return io