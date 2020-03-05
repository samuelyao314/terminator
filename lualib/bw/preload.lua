local skynet = require "skynet"

--print = skynet.error

local env = skynet.getenv("run_env")
if env == "dev" then
    -- 在开发环境下
    -- 开启热更新
    local hotfix_runner = require("bw.hotfix.hotfix_runner")
    import = hotfix_runner.import
else
    import = require
end

skynet.error("preload done")