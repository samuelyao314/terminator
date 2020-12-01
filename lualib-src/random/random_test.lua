local random = require "random"
local lu = require("test.luaunit")


function _G.test_random(t)
	local r = random(0)	-- random generator with seed 0
	local r2 = random(0)

	for i=1,10 do
		local x = r()
		lu.assertTrue(x == r2())
	end

	for i=1,10 do
		local x = r(2)
		lu.assertTrue(x == r2(2))
	end

	for i=1,10 do
		local x = r(0,3)
		lu.assertTrue(x == r2(0,3))
	end
end



os.exit(lu.LuaUnit.run(), true)