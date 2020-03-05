--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki, samuelyao
-- @file        string.lua
--

-- define module: string
local string = string or {}

-- load modules

-- save original interfaces
-- string._dump = string._dump or string.dump

-- find the last substring with the given pattern
function string:find_last(pattern, plain)

    -- find the last substring
    local curr = 0
    repeat
        local next = self:find(pattern, curr + 1, plain)
        if next then
            curr = next
        end
    until (not next)

    -- found?
    if curr > 0 then
        return curr
    end
end

-- split string with the given substring/characters
--
-- pattern match and ignore empty string
-- ("1\n\n2\n3"):split('\n') => 1, 2, 3
-- ("abc123123xyz123abc"):split('123') => abc, xyz, abc
-- ("abc123123xyz123abc"):split('[123]+') => abc, xyz, abc
--
-- plain match and ignore empty string
-- ("1\n\n2\n3"):split('\n', {plain = true}) => 1, 2, 3
-- ("abc123123xyz123abc"):split('123', {plain = true}) => abc, xyz, abc
--
-- pattern match and contains empty string
-- ("1\n\n2\n3"):split('\n', {strict = true}) => 1, , 2, 3
-- ("abc123123xyz123abc"):split('123', {strict = true}) => abc, , xyz, abc
-- ("abc123123xyz123abc"):split('[123]+', {strict = true}) => abc, xyz, abc
--
-- plain match and contains empty string
-- ("1\n\n2\n3"):split('\n', {plain = true, strict = true}) => 1, , 2, 3
-- ("abc123123xyz123abc"):split('123', {plain = true, strict = true}) => abc, , xyz, abc
--
-- limit split count
-- ("1\n\n2\n3"):split('\n', {limit = 2}) => 1, 2\n3
-- ("1.2.3.4.5"):split('%.', {limit = 3}) => 1, 2, 3.4.5
--
function string:split(delimiter, opt)
    local result = {}
    local start = 1
    local pos, epos = self:find(delimiter, start, opt and opt.plain)
    while pos do
        local substr = self:sub(start, pos - 1)
        if (#substr > 0) or (opt and opt.strict) then
            if opt and opt.limit and opt.limit > 0 and #result + 1 >= opt.limit then
                break
            end
            table.insert(result, substr)
        end
        start = epos + 1
        pos, epos = self:find(delimiter, start, opt and opt.plain)
    end
    if start <= #self then
        table.insert(result, self:sub(start))
    end
    return result
end

-- Return a copy of the string with leading characters removed.
function string:lstrip(chars)
    if self == nil then return nil end
    local pattern
    if chars == nil or chars == "" then
        pattern = '^%s+'
    else
        pattern = '^[' .. chars .. ']'
    end
    local s = self:gsub(pattern, '')
    return s
end

-- Return a copy of the string with trailing characters removed.
function string:rstrip(chars)
    if self == nil then return nil end
    local pattern
    if chars == nil or chars == "" then
        pattern = '%s+$'
    else
        pattern = '[' .. chars .. ']$'
    end
    local s = self:gsub(pattern, '')
    return s
end

-- Return a copy of the string with the leading and trailing characters removed.
-- The chars argument is a string specifying the set of characters to be removed.
-- If omitted or None, the chars argument defaults to removing whitespace.
-- The chars argument is not a prefix or suffix; rather, all combinations of its values are stripped.
function string:strip(chars)
    return self:lstrip(chars):rstrip(chars)
end

-- encode: ' ', '=', '\"', '<'
function string:encode()
    return (self:gsub("[%s=\"<]", function (w) return string.format("%%%x", w:byte()) end))
end

-- decode: ' ', '=', '\"'
function string:decode()
    return (self:gsub("%%(%x%x)", function (w) return string.char(tonumber(w, 16)) end))
end

-- try to format
function string.tryformat(format, ...)

    -- attempt to format it
    local ok, str = pcall(string.format, format, ...)
    if ok then
        return str
    else
        return tostring(format)
    end
end

-- case-insensitive pattern-matching
--
-- print(("src/dadasd.C"):match(string.ipattern("sR[cd]/.*%.c", true)))
-- print(("src/dadasd.C"):match(string.ipattern("src/.*%.c", true)))
--
-- print(string.ipattern("sR[cd]/.*%.c"))
--   [sS][rR][cd]/.*%.[cC]
--
-- print(string.ipattern("sR[cd]/.*%.c", true))
--   [sS][rR][cCdD]/.*%.[cC]
--
function string.ipattern(pattern, brackets)
    local tmp = {}
    local i = 1
    while i <= #pattern do
        -- get current charactor
        local char = pattern:sub(i, i)

        -- escape?
        if char == '%' then
            tmp[#tmp + 1] = char
            i = i + 1
            char = pattern:sub(i,i)
            tmp[#tmp + 1] = char

            -- '%bxy'? add next 2 chars
            if char == 'b' then
                tmp[#tmp + 1] = pattern:sub(i + 1, i + 2)
                i = i + 2
            end
        -- brackets?
        elseif char == '[' then
            tmp[#tmp + 1] = char
            i = i + 1
            while i <= #pattern do
                char = pattern:sub(i, i)
                if char == '%' then
                    tmp[#tmp + 1] = char
                    tmp[#tmp + 1] = pattern:sub(i + 1, i + 1)
                    i = i + 1
                elseif char:match("%a") then
                    tmp[#tmp + 1] = not brackets and char or char:lower() .. char:upper()
                else
                    tmp[#tmp + 1] = char
                end
                if char == ']' then break end
                i = i + 1
            end
        -- letter, [aA]
        elseif char:match("%a") then
            tmp[#tmp + 1] = '[' .. char:lower() .. char:upper() .. ']'
        else
            tmp[#tmp + 1] = char
        end
        i = i + 1
    end
    return table.concat(tmp)
end

-- Return True if string starts with the prefix, otherwise return False.
function string:startswith(text)
    local size = text:len()
    if self:sub(1, size) == text then
        return true
    end
    return false
end

-- Return True if the string ends with the specified suffix, otherwise return False.
function string:endswith(text)
    return text == "" or self:sub(-#text) == text
end


--  返回二进制数据 data 的十六进制表示形式
--
function string.hexlify(data)
    return string.gsub(data, ".",
            function(x) return string.format("%02x", string.byte(x)) end)
end

string.b2a_hex = string.hexlify

local function ascii_to_num(c)
    if (c >= string.byte("0") and c <= string.byte("9")) then
        return c - string.byte("0")
    elseif (c >= string.byte("A") and c <= string.byte("F")) then
        return (c - string.byte("A"))+10
    elseif (c >= string.byte("a") and c <= string.byte("f")) then
        return (c - string.byte("a"))+10
    else
        error "Wrong input for ascii to num convertion."
    end
end

-- 返回由十六进制字符串表示的二进制数据
-- 此函数功能与 hexlify 相反
function string.unhexlify(h)
    local s = ""
    for i = 1, #h, 2 do
        local high = ascii_to_num(string.byte(h,i))
        local low = ascii_to_num(string.byte(h,i+1))
        s = s .. string.char((high*16)+low)
    end
    return s
end

string.a2b_hex = string.unhexlify

-- return module: string
return string
