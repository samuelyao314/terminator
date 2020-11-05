--  功能: gate/watchdog/agent三剑客
--  测试方法：~/terminator/skynet]$3rd/lua/lua examples/client.lua
--  测试输入：
--[[
	msg     Welcome to skynet, I will send heartbeat every 5 sec.
	RESPONSE        2
	hello         # 需要查询的 key 值
	Request:        3
	RESPONSE        3
	result  world
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
    skynet.error("-----------start gwagent server.----------------")

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	skynet.error("Watchdog listen on", 8888)
	skynet.exit()
end)

