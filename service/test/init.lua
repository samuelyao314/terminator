local skynet = require "skynet"
local string = require "base.string"


local function test_zset()
    local zset = require "zset"
    local function random_choose(t)
        if #t == 0 then
            return
        end
        local i = math.random(#t)
        return table.remove(t, i)
    end
    local zs = zset.new()
    local total = 100
    local all = {}
    for i=1, total do
        all[#all + 1] = i
    end
    while true do
        local score = random_choose(all)
        if not score then
            break
        end
        local name = "a" .. score
        zs:add(score, name)
    end

    skynet.error("=============== zset ================")
    skynet.error("rank 28:", zs:rank("a28"))
    skynet.error("rev rank 28:", zs:rev_rank("a28"))
    skynet.error("")
end


local function test_cjson()
    local cjson = require "cjson"
    local sampleJson = [[{"age":"23","testArray":{"array":[8,9,11,14,25]},"Himi":"himigame.com"}]];
    local data = cjson.decode(sampleJson)
    skynet.error("=============== cjson ================")
    skynet.error("age:", data["age"])
    skynet.error("array[1]:", data.testArray.array[1])
end


local function test_msgpack()
    local cmsgpack = require "cmsgpack"
    local a = {a1 = 1, a2 = 1, a3 = 1, a4 = 1, a5 = 1, a6 = 1, a7 = 1, a8 = 1, a9 = 1}

    skynet.error("=============== cmsgpack================")
    local encode = cmsgpack.pack(a)
    skynet.error("a: ", string.hexlify(encode))
    local t = cmsgpack.unpack(encode)
    skynet.error("t:", t, "\n")
end


local function test_lfs()
    skynet.error("=============== lfs ================")
	local lfs = require "lfs"
	skynet.error("pwd: ", lfs.currentdir())
end

local function test_protobuf()
    skynet.error("=============== protobuf ================")
    local pb = require "pb"
    local protoc = require "protoc"
    -- load schema from text
    assert(protoc:load [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]])

    -- lua table data
    local data = {
        name = "ilse",
        age  = 18,
        contacts = {
            { name = "alice", phonenumber = 12312341234 },
            { name = "bob",   phonenumber = 45645674567 }
        }
    }

    -- encode lua table data into binary format in lua string and return
    local bytes = assert(pb.encode("Person", data))
    -- and decode the binary data back into lua table
    local data2 = assert(pb.decode("Person", bytes))
    assert(data2.name == data.name)
    assert(data2.contacts[1].phonenumber == data.contacts[1].phonenumber)
end

skynet.start(function()
    skynet.newservice("debug_console",8000)
    skynet.error("Be water my friend.")

    test_zset()
    test_cjson()
    test_msgpack()
	test_lfs()
    test_protobuf()
end)
