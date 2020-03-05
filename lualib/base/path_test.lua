local lu = require("test.luaunit")

local path = require("base.path")

function _G.test_split(t)
    lu.assertEquals(path.split(""), {})
    lu.assertEquals(path.split("a"), {'a'})
    lu.assertEquals(path.split("/a/b"), {'a','b'})
end


os.exit(lu.LuaUnit.run(), true)