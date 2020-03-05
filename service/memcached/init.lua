--  实现 memcached 服务
--  网络编程实践: 例子 memecached
local skynet = require "skynet"
local socket = require "skynet.socket"
local class = require "base.class"
local string = require "base.string"

-- 监听端口
local host = "127.0.0.1"
local port = 10001

-- 值类型
-- @class CValue
local CValue = class()

function CValue:Ctor(flags, exptime, cas, val)
    self.flags = flags
    self.exptime = exptime
    self.cas = cas
    self.val = val
end

function CValue:get_val()
    return self.val
end


-- 当前只支持一个存储 [key -> Value]
local storage = {}
-- 命令表
local commands = {}

commands.set = function (id, key, flags, exptime, bytes)
    local nbytes = tonumber(bytes)
    local data = socket.readline(id, "\r\n")
    if #data ~= nbytes then
        skynet.error("invalid data length", #data, nbytes)
        return
    end
    skynet.error("data", data)
    local v = CValue(flags, exptime, 0, data)
    storage[key] = v
    skynet.error("set", key, storage[key].val)
    socket.write(id, "STORED\r\n")
    end

commands.get = function(id, key)
    local v = storage[key]
    skynet.error("get", key, v:get_val())
    if v then
        socket.write(id, v:get_val() .. "\r\n")
    end
    socket.write(id, "END\r\n")
end


local function handler(id, addr)
    while true do
        local line = socket.readline(id, "\r\n")
        local args = string.split(line, "%s+")
        local cmd = args[1]
        skynet.error("cmd: ", cmd)
        if cmd == 'quit' then
            break
        end
        commands[cmd](id, table.unpack(args, 2))
    end
    socket.close(id)
end


local function start_server()
    local listen_id = socket.listen(host, port)
    assert(listen_id)
    skynet.error("listen id: ", listen_id)
    socket.start(listen_id, function(id, addr)
        skynet.error("client id: ", id, ", addr: ", addr)
        socket.start(id)                 -- 这行很重要. 否则id 不可读.
        skynet.fork(handler, id, addr)
    end)
end


--[[ 例子：
(python3) samuel@workspace$ telnet 127.0.0.1 10001
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
set hello 0 0 5
world
STORED
get hello
world
END
--]]
skynet.start(function()
    skynet.error("-----------start memcached server.----------------")
    start_server()
end)
