local lu = require("test.luaunit")

local url = require("base.url")

function _G.test_escape()
    local s = "a%2Bb+%3D+c"
    local s2 = "a+b = c"
    lu.assertTrue(url.unescape(s) == s2)
    lu.assertTrue(url.escape(s2) == s)
end

function _G.test_encode()
    local t = {name = "al", query = "a+b = c", q = "yes or no"}
    local expect = "name=al&q=yes+or+no&query=a%2Bb+%3D+c"
    lu.assertTrue(url.encode(t) == expect)
end

os.exit(lu.LuaUnit.run(), true)