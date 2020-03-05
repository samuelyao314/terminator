--  实现 TTCP 服务
--  类似 https://github.com/chenshuo/muduo/blob/master/examples/ace/ttcp/ttcp_blocking.cc
local skynet = require "skynet"
local socket = require "skynet.socket"

local host = "127.0.0.1"
local port = 10001


local function handler(id, addr)
    local fmt = ">ii"
    local size = string.packsize(fmt)
    local data, succ = socket.read(id, size)
    if false == succ then
        skynet.error("read failed, id: ", id, ", addr: ", addr)
        return
    end
    local session_message = {number = 0, length = 0}
    session_message.number, session_message.length = string.unpack(fmt, data)

    -- 读取 PlayLoadMessage
    for i = 1, session_message.number do
        --skynet.error("loop: i ", i)
        local fmt2 = ">i"
        local size2 = string.packsize(fmt2)
        local data2 = socket.read(id, size2)
        local payload = {length = 0, data = ""}
        payload.length = string.unpack(fmt2, data2)
        --skynet.error("payload.length:", payload.length)
        assert(payload.length == session_message.length)
        payload.data = socket.read(id, session_message.length)
        local ack = string.pack('>i', payload.length)
        socket.write(id, ack)
    end
end


local function ttcp_server()
    local listen_id = socket.listen(host, port)
    assert(listen_id)
    skynet.error("listen id: ", listen_id)
    socket.start(listen_id, function(id, addr)
        skynet.error("client id: ", id, ", addr: ", addr)
        socket.start(id)                 -- 这行很重要. 否则id 不可读.
        skynet.fork(handler, id, addr)
    end)
end


-- 客户端. 行为类似  ./ttcp_blocking --trans 127.0.0.1  -p 10001 --length 1024 -n 10
local function ttcp_client()
    local session_message = {number = 10000, length = 8192}
    skynet.error("port", port)
    skynet.error("buffer length", session_message.length)
    skynet.error("connecting to ", host, ":", port)
    local id = socket.open(host, port)
    assert(id)
    skynet.error("connected")
    -- 这里可以修改
    local stime = skynet.time()
    local data = string.pack(">ii", session_message.number, session_message.length)
    socket.write(id, data)
    for i = 1, session_message.number do
        local payload = string.rep("a", session_message.length)
        socket.write(id, string.pack(">s4", payload))
        local fmt = ">i"
        local size = string.packsize(fmt)
        local body = socket.read(id, size)
        local ack = string.unpack(fmt, body)
        --skynet.error("loop, i: ", i, ", ack: ", ack)
        assert(ack == session_message.length)
    end
    local etime = skynet.time()
    local seconds = etime - stime
    local total_mib = session_message.number * session_message.length / 1024 / 1024
    skynet.error(string.format("%.2f MiB in total", total_mib))
    skynet.error(string.format("%.2f seconds", seconds))
    -- 吞吐量
    local throughput = session_message.number / seconds;
    skynet.error(string.format("throughput: %.2f req/s", throughput))
    -- 平均延迟
    local latency = seconds / session_message.number
    skynet.error(string.format("latency: %.6f", latency))
end


skynet.start(function()
    skynet.error("-----------start ttcp server.----------------")
    ttcp_server()
    ttcp_client()
end)
