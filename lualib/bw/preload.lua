local skynet = require "skynet"

-- 替换标准输出
print = skynet.error

local need_hotfix = skynet.getenv("need_hotfix")
if need_hotfix then
    -- 开启热更新
    local hotfix_runner = require("bw.hotfix.hotfix_runner")
    import = hotfix_runner.import
else
    import = require
end

skynet.error("preload done")