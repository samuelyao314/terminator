local lru = require("lru")
local t = {}
local lu = require("test.luaunit")

function t.equal(val1, val2)
    lu.assertEquals(val1, val2)
end

function t.basic()
    local cache = lru.new(10, "string", "map")
    cache:set('key', 'value')

    t.equal(cache:get('key'), 'value')
    t.equal(cache:get('nada'), nil)

    cache = lru.new(10, "integer", "map")
    cache:set(5, 6)

    t.equal(cache:get(5), 6)
    t.equal(cache:get(1), nil)

    cache = lru.new(10, "string", "hashmap")
    cache:set('key', 'value')

    t.equal(cache:get('key'), 'value')
    t.equal(cache:get('nada'), nil)

    cache = lru.new(10, "integer", "hashmap")
    cache:set(5, 6)

    t.equal(cache:get(5), 6)
    t.equal(cache:get(1), nil)
end

function t.set_with_discard()
    local cache = lru.new(10, "integer", "map")
    local discard_times = 0

    -- container is not full.
    for i = 1, 10 do
        cache:set(i, i + 100, function(k, v)
            discard_times = discard_times + 1
        end)
    end
    t.equal(discard_times, 0)

    -- duplicate keys.
    for i = 1, 10 do
        cache:set(i, i + 100, function(k, v)
            discard_times = discard_times + 1
        end)
    end
    t.equal(discard_times, 0)

    -- container is full.
    for i = 1, 10 do
        cache:set(i + 10, i + 10 + 100, function(k, v)
            t.equal(k, i)
            t.equal(v, i + 100)

            discard_times = discard_times + 1
        end)
    end

    t.equal(discard_times, 10)

    -- callback error
    cache:set(1024, 1024, function(k, v)
        t.equal(k, 11)
        t.equal(v, 11 + 100)

        assert(false)
    end)
    t.equal(cache:get(1024), 1024)
end

function t.least_recently_set()
    local cache = lru.new(2, "string")
    cache:set('a', 'A')
    cache:set('b', 'B')
    cache:set('c', 'C')

    t.equal(cache:get('c'), 'C')
    t.equal(cache:get('b'), 'B')
    t.equal(cache:get('a'), nil)
end

function t.lru_recently_gotten()
    local cache = lru.new(2, "string")
    cache:set('a', 'A')
    cache:set('b', 'B')
    cache:get('a')
    cache:set('c', 'C')

    t.equal(cache:get('c'), 'C')
    t.equal(cache:get('b'), nil)
    t.equal(cache:get('a'), 'A')
end

function t.del()
    local cache = lru.new(2, "string")
    cache:set('a', 'A')
    cache:del('a')
    t.equal(cache:get('a'), nil)
end

function t.resize()
    local cache = lru.new(2, "integer")

    -- test changing the max, verify that the LRU items get dropped.
    cache:resize(100)
    for i = 0, 99 do
        cache:set(i, i)
    end

    t.equal(cache:count(), 100)

    for i = 0, 99 do
        t.equal(cache:get(i), i)
    end

    cache:resize(3)
    t.equal(cache:count(), 3)

    for i = 0, 96 do
        t.equal(cache:get(i), nil)
    end

    for i = 97, 99 do
        t.equal(cache:get(i), i)
    end

    cache:resize(20)
    for i = 0, 96 do
        t.equal(cache:get(i), nil)
    end

    for i = 97, 99 do
        t.equal(cache:get(i), i)
    end
end

function t.clear()
    local cache = lru.new(10, "string")
    cache:set('a', 'A')
    cache:set('b', 'B')
    cache:clear()
    t.equal(cache:count(), 0)
    t.equal(cache:get('a'), nil)
    t.equal(cache:get('b'), nil)
end

function t.delete_non_existent()
    local cache = lru.new(2, "string")
    cache:set('foo', 1)
    cache:set('bar', 2)
    cache:del('baz')
    t.equal(cache:get('foo'), 1)
    t.equal(cache:get('bar'), 2)
end

function t.next()
    local count = 128
    local cache = lru.new(count, "integer")
    local check = {}
    for i = 1, count * 2 do
        cache:set(i, 0)
    end
    for i = 10000, 10000 + count - 1 do
        cache:set(i, i)
        check[i] = i
    end
    local key = nil
    while true do
        local k, v = cache:next(key)
        if not k then
            break
        end
        t.equal(v, check[k])
        check[k] = nil
        key = k
    end
    t.equal(next(check), nil)
end

function t.pairs()
    local count = 128
    local cache = lru.new(count, "integer")
    local check = {}
    for i = 1, count * 2 do
        cache:set(i, 0)
    end
    for i = 10000, 10000 + count - 1 do
        cache:set(i, i)
        check[i] = i
    end

    for k, v in pairs(cache) do
        t.equal(v, check[k])
        check[k] = nil
    end
    t.equal(next(check), nil)
end

local function print_traceback(msg)
    print(debug.traceback(msg))
end

for _, v in pairs(t) do
    local ret = xpcall(v, print_traceback)
    assert(ret)
end