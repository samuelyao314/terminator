local lu = require("test.luaunit")

local table = require("base.table")

function _G.test_contain()
    local t = {"a", "b", "c"}
    lu.assertTrue(table.contains(t, "a"))
    lu.assertFalse(table.contains(t, "d"))

end


os.exit(lu.LuaUnit.run(), true)