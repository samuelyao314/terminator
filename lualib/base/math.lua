--------------------------------------
----- 对标准库 math 的补充
-------------------------------------

-- define module
local math = math or {}

-- init constants
math.nan   = math.log(-1)
math.e     = math.exp(1)

-- check a number is int
--
-- @returns true for int, otherwise false
--
function math:isint()
    -- check
    assert(type(self) == "number", "number expacted")
    return self == math.floor(self) and self ~= math.huge and self ~= -math.huge
end

-- check a number is inf or -inf
--
-- @returns 1 for inf,  -1 for -inf, otherwise false
--
function math:isinf()
    -- check
    assert(type(self) == "number", "number expacted")
    if self == math.huge then
        return 1
    elseif self == -math.huge then
        return -1
    else
        return false
    end
end

-- check a number is nan
--
-- @returns true for nan, otherwise false
--
function math:isnan()
    -- check
    assert(type(self) == "number", "number expacted")

    return self ~= self
end


-- return module
return math