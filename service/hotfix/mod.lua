local test = {}
test.count = 10
count = 10
local d_count = 20
function test.func()
    count = count + 200
    d_count = d_count + 100
    test.count = test.count + 100
    print("test", count, d_count, test.count)
    return true
end
return test