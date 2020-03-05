--  服务: 提供数独答案
--  https://blog.csdn.net/Solstice/article/details/2096209
--  例子1: 输入,  "000000010400000000020000000000050407008000300001090000300400200050100000000806000\r\n"
--         结果:  "693784512487512936125963874932651487568247391741398625319475268856129743274836159\r\n"

local skynet = require "skynet"
local socket = require "skynet.socket"

local sudoku = require "sudoku"


-- 监听端口
local host = "127.0.0.1"
local port = 9871

local function handler(id, addr)
    while true do
        local puzzle = socket.readline(id, "\r\n")
        if not puzzle then
            break
        end
        skynet.error("puzzle: ", puzzle)
        local result = sudoku.solve(puzzle)
        skynet.error("result:", result)
        socket.write(id, result .. "\r\n")
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



skynet.start(function()
    skynet.error("-----------start sudoku server.----------------")
    start_server()
end)
