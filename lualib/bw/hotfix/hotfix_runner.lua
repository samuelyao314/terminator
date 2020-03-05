local _M = {}

local skynet = require "skynet"
local table = require("base.table")
local hotfix_helper = require("bw.hotfix.hotfix_helper")
local hotfix_module_names = require("bw.hotfix.hotfix_module_names")

-- 热更新模块初始化
hotfix_helper.init()

-- 触发热更新的时间间隔，单位是0.01s
local delay = 100
local function hot_update_cb()
    hotfix_helper.check()
    skynet.timeout(delay, hot_update_cb)
end


local start = false

-- 增加模块，到热更新列表
-- @param mod, 需要进行热更新的模块
-- @RET，返回模块
function _M.import(mod)
    if not table.contains(hotfix_module_names, mod) then
        -- 保证不重复
        table.insert(hotfix_module_names, mod)
    end
    local m = require(mod)
    if not start then
        skynet.timeout(delay, hot_update_cb)
        start = true
    end

    return m
end

return _M