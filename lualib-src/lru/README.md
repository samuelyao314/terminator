# lru

lru是一个c++实现的lua lru(least recently used)库。

## 主要接口说明

```lua
lru = require("lru");

--创建容量大小为50的lru容器, 其中key为整数类型，内部采用红黑树算法
--第二个参数： "integer" 整型， "string" 字符串
--第三个参数： "map" 红黑树， "hashmap" 散列表，默认值 "map"
cache = lru.new(50, "integer", "map");

-- 添加或修改容器中元素，key必须是创建时指定的类型，value可以是lua的任意类型, discard_callback 可以在lru淘汰元素时，回调该函数
cache:set(1, "1");
cache:set(2, {2});
cache:set(3, 3, function(k, v)
    print("discard", k, v)
end);

-- 查询
cache:get(1);

-- 删除
cache:del(1);

-- 获取元素数
count = cache:count();
count = #cache;

-- 调整大小
cache:resize(100);

-- 清空
cache:clear();

-- 遍历
for k, v in pairs(cache) do
    print(k, v);
end

local k, v;
while true do
    k, v = cache:next(k);
    if not k then
        break;
    end
    print(k, v);
end

```
