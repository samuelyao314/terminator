local lu = require("test.luaunit")

local math = require("base.math")

function _G.test_isinf(t)
    lu.assertError(function() math.isinf(nil) end)
    lu.assertError(function() math.isinf(true) end)
    lu.assertFalse(math.isinf(0))
    lu.assertFalse(math.isinf(math.nan))
    lu.assertIs(math.isinf(math.huge), 1)
    lu.assertIs(math.isinf(-math.huge), -1)
end

function _G.test_isnan(t)
    lu.assertError(function() math.isinf(nil) end)
    lu.assertError(function() math.isinf(true) end)

    lu.assertFalse(math.isnan(0))
    lu.assertTrue(math.isnan(math.nan))
    lu.assertFalse(math.isnan(math.huge))
    lu.assertFalse(math.isnan(-math.huge))
end

function _G.test_isint(t)
    lu.assertError(function() math.isint(nil) end)
    lu.assertError(function() math.isint(true) end)

    lu.assertTrue(math.isint(0))
    lu.assertTrue(math.isint(-10))
    lu.assertTrue(math.isint(123456))
    lu.assertFalse(math.isint(123456.1))
    lu.assertFalse(math.isint(-9.99))
    lu.assertFalse(math.isint(math.nan))
    lu.assertFalse(math.isint(math.huge))
    lu.assertFalse(math.isint(-math.huge))
end

os.exit(lu.LuaUnit.run(), true)