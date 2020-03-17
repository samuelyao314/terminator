local lu = require("test.luaunit")

local os = require("base.os")

function _G.test_get_file_size(t)
    local size = os.get_file_size("run.sh")
    lu.assertEquals(size, 119)
end


os.exit(lu.LuaUnit.run(), true)