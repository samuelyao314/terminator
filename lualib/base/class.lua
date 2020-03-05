-- 类实现
-- 来自 https://www.cnblogs.com/yaukey/p/4547882.html

-- The hold all class type.
local __TxClassTypeList = {}

-- The inherit class function.
local function TxClass(SuperType)
    -- Create new class type.
    local ClassType = {}
    ClassType.Ctor = false
    ClassType.SuperType = SuperType

    -- Create new class instance function.
    local function ClassTypeInstance(...)
        local Obj = {}
            do
                local Create
                Create = function (c, ...)
                    if c.SuperType then
                        Create(c.SuperType, ...)
                    end

                    if c.Ctor then
                        c.Ctor(Obj, ...)
                    end
                end
                Create(ClassType, ...)
            end

            setmetatable(Obj, {__index = __TxClassTypeList[ClassType]})
            return Obj
    end

    -- The new function of this class.
    ClassType.new = ClassTypeInstance

    -- The super class type of this class.
    if SuperType then
        ClassType.super = setmetatable({},
        {
            __index = function (t, k)
                local Func = __TxClassTypeList[SuperType][k]
                if "function" == type(Func) then
                    t[k] = Func
                    return Func
                else
                    error("Accessing super class field are not allowed!")
                end
            end
        })
    end

    -- Virtual table
    local Vtbl = {}
    --print('Vtbl', Vtbl)
    __TxClassTypeList[ClassType] = Vtbl

    -- Set index and new index of ClassType, and provide a default create method.
    setmetatable(ClassType,
    {
        __index = function (t, k)
            return Vtbl[k]
        end,

        __newindex = function (t, k, v)
            Vtbl[k] = v
            --print('set vtbl', k, v)
        end,

        __call = function (self, ...)
            return ClassTypeInstance(...)
        end
    })

    -- To copy super class things that this class not have.
    if SuperType then
        setmetatable(Vtbl,
        {
            __index = function (t, k)
                local Ret = __TxClassTypeList[SuperType][k]
                Vtbl[k] = Ret
                return Ret
            end
        })
    end

    return ClassType
end

return TxClass
