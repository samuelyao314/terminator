local lu = require("test.luaunit")

local string = require("base.string")

function _G.test_endswith()
    lu.assertTrue(("aaaccc"):endswith("ccc"))
    lu.assertTrue(("aaaccc"):endswith("aaaccc"))
    lu.assertFalse(("rc"):endswith("xcadas"))
    lu.assertFalse(("aaaccc "):endswith("%s"))
end

function _G.test_startswith()
    lu.assertTrue(("aaaccc"):startswith("aaa"))
    lu.assertTrue(("aaaccc"):startswith("aaaccc"))
    lu.assertFalse(("rc"):startswith("xcadas"))
    lu.assertFalse(("  aaaccc"):startswith("%s"))
end

function _G.test_strip()
    lu.assertEquals((""):strip(), "")
    lu.assertEquals(("   "):strip(), "")
    lu.assertEquals((""):strip(""), "")
    lu.assertEquals(("   "):strip(""), "")
    lu.assertEquals(("   aaa ccc   "):strip(), "aaa ccc")
    lu.assertEquals(("aaa ccc   "):strip(), "aaa ccc")
    lu.assertEquals(("   aaa ccc"):strip(), "aaa ccc")
    lu.assertEquals(("aaa ccc"):strip(), "aaa ccc")
    lu.assertEquals(("\t\naaa ccc\r\n"):strip(), "aaa ccc")
    lu.assertEquals(("aba"):strip("a"), "b")
end

function _G.test_lstrip()
    lu.assertEquals((""):lstrip(), "")
    lu.assertEquals(("   "):lstrip(), "")
    lu.assertEquals((""):lstrip(""), "")
    lu.assertEquals(("   "):lstrip(""), "")
    lu.assertEquals(("   aaa ccc   "):lstrip(), "aaa ccc   ")
    lu.assertEquals(("aaa ccc   "):lstrip(), "aaa ccc   ")
    lu.assertEquals(("   aaa ccc"):lstrip(), "aaa ccc")
    lu.assertEquals(("aaa ccc"):lstrip(), "aaa ccc")
    lu.assertEquals(("\t\naaa ccc\r\n"):lstrip(), "aaa ccc\r\n")
    lu.assertEquals(("aba"):lstrip("a"), "ba")
end

function _G.test_rstrip()
    lu.assertEquals((""):rstrip(), "")
    lu.assertEquals(("   "):rstrip(), "")
    lu.assertEquals((""):rstrip(""), "")
    lu.assertEquals(("   "):rstrip(""), "")
    lu.assertEquals(("   aaa ccc   "):rstrip(), "   aaa ccc")
    lu.assertEquals(("aaa ccc   "):rstrip(), "aaa ccc")
    lu.assertEquals(("   aaa ccc"):rstrip(), "   aaa ccc")
    lu.assertEquals(("aaa ccc"):rstrip(), "aaa ccc")
    lu.assertEquals(("\t\naaa ccc\r\n"):rstrip(), "\t\naaa ccc")
    lu.assertEquals(("aba"):rstrip("a"), "ab")
end

function _G.test_split()
    -- pattern match and ignore empty string
    lu.assertEquals(("1\n\n2\n3"):split('\n'), {"1", "2", "3"})
    lu.assertEquals(("abc123123xyz123abc"):split('123'), {"abc", "xyz", "abc"})
    lu.assertEquals(("abc123123xyz123abc"):split('[123]+'), {"abc", "xyz", "abc"})

    -- plain match and ignore empty string
    lu.assertEquals(("1\n\n2\n3"):split('\n', {plain = true}), {"1", "2", "3"})
    lu.assertEquals(("abc123123xyz123abc"):split('123', {plain = true}), {"abc", "xyz", "abc"})

    -- pattern match and contains empty string
    lu.assertEquals(("1\n\n2\n3"):split('\n', {strict = true}), {"1", "", "2", "3"})
    lu.assertEquals(("abc123123xyz123abc"):split('123', {strict = true}), {"abc", "", "xyz", "abc"})
    lu.assertEquals(("abc123123xyz123abc"):split('[123]+', {strict = true}), {"abc", "xyz", "abc"})

    -- plain match and contains empty string
    lu.assertEquals(("1\n\n2\n3"):split('\n', {plain = true, strict = true}), {"1", "", "2", "3"})
    lu.assertEquals(("abc123123xyz123abc"):split('123', {plain = true, strict = true}), {"abc", "", "xyz", "abc"})

    -- limit split count
    lu.assertEquals(("1\n\n2\n3"):split('\n', {limit = 2}), {"1", "2\n3"})
    lu.assertEquals(("1\n\n2\n3"):split('\n', {limit = 2, strict = true}), {"1", "\n2\n3"})
    lu.assertEquals(("1.2.3.4.5"):split('%.', {limit = 3}), {"1", "2", "3.4.5"})
    lu.assertEquals(("123.45"):split('%.', {limit = 3}), {"123", "45"})
end

function _G.test_hexlify()
    local s = "helloworld\n"
    local data = string.hexlify(s)
    lu.assertEquals(data, "68656c6c6f776f726c640a")
end

function _G.test_unhexlify()
    local data = "68656c6c6f776f726c640a"
    local s = string.unhexlify(data)
    lu.assertEquals(s, "helloworld\n")
end



os.exit(lu.LuaUnit.run(), true)