--  热更新机制，基于https://github.com/jinq0123/hotfix
--- Hotfix helper which hotfixes modified modules.
--  Using lfs to detect files' modification.
--  建议：只用在开发环境
local M = { }

local skynet = require("skynet")
local lfs = require("lfs")
local hotfix = require("hotfix.hotfix")

-- Map file path to file time to detect modification.
local path_to_time = { }

-- global_objects which must not hotfix.
local global_objects = {
    arg,
    assert,
    collectgarbage,
    coroutine,
    debug,
    dofile,
    error,
    getmetatable,
    io,
    ipairs,
    lfs,
    load,
    loadfile,
    math,
    next,
    os,
    package,
    pairs,
    pcall,
    print,
    rawequal,
    rawget,
    rawlen,
    rawset,
    require,
    select,
    setmetatable,
    string,
    table,
    tonumber,
    tostring,
    type,
    utf8,
    xpcall,
    skynet,        -- skynet 模块不能够热更
}

--- Check modules and hotfix.
function M.check()
    local MOD_NAME = "bw.hotfix.hotfix_module_names"
    if not package.searchpath(MOD_NAME, package.path) then return end
    -- package.loaded[MOD_NAME] = nil  -- always reload it
    local module_names = require(MOD_NAME)

    for _, module_name in pairs(module_names) do
        local path, err = package.searchpath(module_name, package.path)
        -- Skip non-exist module.
        if not path then
            skynet.error(string.format("No such module: %s. %s", module_name, err))
            goto continue
        end

        local file_time = lfs.attributes (path, "modification")
        if file_time == path_to_time[path] then goto continue end

        skynet.error(string.format("Hot fix module %s (%s)", module_name, path))
        path_to_time[path] = file_time
        hotfix.hotfix_module(module_name)
        ::continue::
    end  -- for
end  -- check()

function M.init()
    hotfix.log_debug = function(s) skynet.error(s) end
    hotfix.add_protect(global_objects)
end

return M
