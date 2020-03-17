 ---
 --- url.lua
 --- URL encoding
 ---
local url = {}

local function unescape (s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function (h)
    return string.char(tonumber(h, 16))
    end)
    return s
end
url.unescape = unescape

url.decode = function (s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name)
        value = unescape(value)
        cgi[name] = value
    end
    return cgi
end

local function escape (s)
    s = string.gsub(s, "[&=+%%%c]", function (c)
        return string.format("%%%02X", string.byte(c))
    end)
    s = string.gsub(s, " ", "+")
    return s
end
url.escape = escape

url.encode = function (t)
    local b = {}
    for k,v in pairs(t) do
        b[#b + 1] = (escape(k) .. "=" .. escape(v))
    end
    table.sort(b)
    return table.concat(b, "&")
end

return url