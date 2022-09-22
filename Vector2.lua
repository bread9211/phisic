local Vector2 = {}
Vector2.__index = Vector2

function Vector2:new(x, y)
    local o = {}
    setmetatable(o, self)

    o.x = x or 0
    o.y = y or 0
    o.Magnitude = function ()
        return math.abs(math.sqrt(o.x^2 + o.y^2))
    end
    
    o.__add = function (a, b)
        return Vector2:new(a.x+b.x, a.y+b.y)
    end
    o.__sub = function (a, b)
        return Vector2:new(a.x-b.x, a.y-b.y)
    end
    o.__mul = function (a, b)
        if (type(a) == "number") then
            return Vector2:new(a*b.x, a*b.y)
        elseif (type(b) == "number") then
            return Vector2:new(a.x*b, a.y*b)
        else
            return Vector2:new(a.x*b.x, a.y*b.y)
        end
    end
    o.__div = function (a, b)
        if (type(a) == "number") then
            return Vector2:new(a/b.x, a/b.y)
        elseif (type(b) == "number") then
            return Vector2:new(a.x/b, a.y/b)
        else
            return Vector2:new(a.x/b.x, a.y/b.y)
        end
    end

    return o
end