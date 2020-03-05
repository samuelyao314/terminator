local skynet = require "skynet"
local socket = require "skynet.socket"


local host = "127.0.0.1"
local port = 8765
local pack_fmt = 'i8i8'


local function current_time()
    local now = skynet.time()  -- 单位是秒
    return now * 1000000  -- 单位是 us
end


local function udp_server()
    local id
    id = socket.udp(function (str, from)
        local size = string.packsize(pack_fmt)
        skynet.error("server, receive message, size: ", #str, ", from: ",
                       socket.udp_address(from), ", packsize: ", size)
        if size == #str then
            local t1, t2 = string.unpack(pack_fmt, str)
            assert(t2 == 0)
            local message = {t1, 0}
            message[2] = current_time()
            local resp = string.pack(pack_fmt, message[1], message[2])
            --skynet.error("message: ", message[1], message[2])
            socket.sendto(id, from, resp)
        end
    end, host, port)
end


local function udp_client()
	local id = socket.udp(function(str, from)
		--print("client recv, size:", #str, ", from: ", socket.udp_address(from))
        local size = string.packsize(pack_fmt)
        if size == #str then
            local t1, t2 = string.unpack(pack_fmt, str)
            local back = current_time()
            local mine = (back + t1) / 2;
            local msg = string.format("client, now %d round trip %d clock error %d\n", back, back - t1, t2 - mine)
            skynet.error(msg)
        end
	end)
    socket.udp_connect(id, host, port)
    for i=1, 20 do
        local now = current_time()
        local data = string.pack(pack_fmt, now, 0)
        socket.write(id, data)
        skynet.sleep(10)
    end
end



skynet.start(function()
    skynet.fork(udp_server)
    skynet.fork(udp_client)
end)
