local window = js.global
local document = window.document
local c = document:getElementById("screen")
local ctx = c:getContext("2d")

-- local ball = require "ball"
local spawnType = "ball"

local instances = {}

local time = os.clock()

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

local Ball = {}
Ball.__index = Ball

function Ball:new(x, y, density, radius)
    local o = {}
    setmetatable(o, self)

    self.vecPos = Vector2:new(x, y)
    self.vecVel = Vector2:new()
    self.vecAcc = Vector2:new()
    self.properties = {
        density = density,
        radius = radius,
        airResist = 1,
    }

    self.lastUpdate = 0

    return o
end

function Ball:update(t, instance)
    local lowerLimit = 200-self.properties.radius

    local mass = self.properties.density * math.pi*self.properties.radius^2

    local netX = mass * self.vecAcc.x
    local netY = mass * self.vecAcc.y - 9.8*mass

    for i in ipairs(instance) do
        if ((i.vecPos-self.vecPos).Magnitude() <= 1) then
            local iMass = i.properties.density * math.pi*i.properties.radius^2
            netX = netX + iMass * i.vecAcc.x
            netY = netY + iMass * i.vecAcc.y
        end
    end

    if (self.vecPos.y >= lowerLimit) and (netY < 0) then
        netY = 0
    end

    local dT = t - self.lastUpdate

    local vecPosX = self.vecVel.x*dT + (self.vecAcc.x*dT^2)/2
    local vecPosY = self.vecVel.y*dT + (self.vecAcc.y*dT^2)/2

    local vecVelX = self.vecVel.x + self.vecAcc.x*dT
    local vecVelY = self.vecVel.y + self.vecAcc.y*dT

    local vecAccX = netX / mass
    local vecAccY = netY / mass

    self.vecPos = Vector2:new(vecPosX, vecPosY)
    self.vecVel = Vector2:new(vecVelX, vecVelY)
    self.vecAcc = Vector2:new(vecAccX, vecAccY)
end

document:getElementById("balls"):addEventListener("click", function ()
    document:getElementById("debug").value = #instances .. spawnType

    spawnType = "ball"
end)

document:getElementById("bombs"):addEventListener("click", function ()
    document:getElementById("debug").value = #instances .. spawnType

    spawnType = "bomb"
end)

c:addEventListener("mousedown", function (event)
    document:getElementById("debug").value = #instances .. spawnType

    local rect = c:getBoundingClientRect()
    local x = event.clientX - rect.left
    local y = event.clientY - rect.top
    table.insert(instances, Ball:new(x, y, 1, 1))
end)

local function update()
    window:requestAnimationFrame(update)

    for i in ipairs(instances) do
        i:update(os.clock() - time, instances)
        ctx.fillStyle = "#000000"
        ctx:beginPath()
        ctx:arc(i.vecPos.x-i.properties.radius, i.vecPos.y-i.properties.radius, 0, 2*math.pi) 
        ctx:stroke()
    end
end

window:requestAnimationFrame(update)