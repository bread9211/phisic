local window = js.global
local document = window.document
local c = document:getElementById("screen")
local ctx = c:getContext("2d")

-- local ball = require "ball"
local spawnType = "ball"

local instances = {}
local instanceCount = 0

local time = os.clock()
local checked = {}

local Vector2 = {}
Vector2.__index = Vector2

local Ball = {}
local BallMT = {__index = Ball}

-- Vector2 object for Ball
function Vector2:new(x, y)
    local o = {}
    local mt = {}
    setmetatable(o, self)

    o.x = x or 0
    o.y = y or 0
    o.Magnitude = function ()
        return math.abs(math.sqrt(o.x^2 + o.y^2))
    end
    
    mt.__add = function (a, b)
        return Vector2:new(a.x+b.x, a.y+b.y)
    end
    mt.__sub = function (a, b)
        return Vector2:new(a.x-b.x, a.y-b.y)
    end
    mt.__mul = function (a, b)
        if (type(a) == "number") then
            return Vector2:new(a*b.x, a*b.y)
        elseif (type(b) == "number") then
            return Vector2:new(a.x*b, a.y*b)
        else
            return Vector2:new(a.x*b.x, a.y*b.y)
        end
    end
    mt.__div = function (a, b)
        if (type(a) == "number") then
            return Vector2:new(a/b.x, a/b.y)
        elseif (type(b) == "number") then
            return Vector2:new(a.x/b, a.y/b)
        else
            return Vector2:new(a.x/b.x, a.y/b.y)
        end
    end

    o = setmetatable(o, mt)
    return o
end

-- Ball object
function Ball:new(x, y, density, radius, airDrag, elasticity, groundFriction)
    local self = {}

    self.vecPos = Vector2:new(x, y)
    self.vecVel = Vector2:new(0, 0)
    self.properties = {
        density = density,
        radius = radius,
        airDrag = airDrag,
        elasticity = elasticity,
        groundFriction = groundFriction,
    }

    self.lastUpdate = 0

    return setmetatable(self, BallMT)
end

function Ball:update()
    for _, v in ipairs(instances) do
        if (self.vecPos-v.vecPos).Magnitude() < (self.properties.radius+v.properties.radius) and (self ~= v) and !(checked[v]==1) then
            local normal = self.vecPos - v.vecPos
            local reflectionVX = self.vecVel.x - normal.x*(2*self.vecVel.x*normal.x)
            local reflectionVY = self.vecVel.y - normal.y*(2*self.vecVel.x*normal.y)
            window.console:log(reflectionVX .. " " .. reflectionVY)
            self.vecVel.x = self.vecVel.x + reflectionVX*10
            self.vecVel.y = self.vecVel.y + reflectionVY*10

            checked[v] = 1
        else
            checked[v] = nil
        end
    end

    self.vecPos.x = self.vecPos.x + self.vecVel.x
    self.vecPos.y = self.vecPos.y + self.vecVel.y

    if (self.vecPos.y >= c.height - self.properties.radius) then
        self.vecPos.y = c.height - self.properties.radius
        self.vecVel.y = -(self.vecVel.y * self.properties.elasticity)
    end

    if (self.vecPos.x >= c.width - self.properties.radius) or (self.vecPos.x <= self.properties.radius) then
        if (self.vecPos.x <= self.properties.radius) then
            self.vecPos.x = self.properties.radius
        else
            self.vecPos.x = c.width - self.properties.radius
        end
        self.vecVel.x = -(self.vecVel.x * self.properties.elasticity)
    end


    self.vecVel.y = self.vecVel.y + 0.98

    self.vecVel.x = self.vecVel.x * self.properties.airDrag
    self.vecVel.y = self.vecVel.y * self.properties.airDrag
    if (self.vecPos.y >= (c.height - self.properties.radius)) then
        self.vecVel.x = self.vecVel.x * self.properties.groundFriction;
    end
end

document:getElementById("balls"):addEventListener("click", function ()
    document:getElementById("debug").value = instanceCount .. spawnType

    spawnType = "ball"
end)

document:getElementById("bombs"):addEventListener("click", function ()
    document:getElementById("debug").value = instanceCount .. spawnType

    spawnType = "bomb"
end)

local function updateMouse(_, e)
    local rect = c:getBoundingClientRect()
    local x = e.clientX - rect.left
    local y = e.clientY - rect.top

    local newBall = Ball:new(x, y, 1, 5, 0.99, 0.5, 0.98)
    instances[instanceCount+1] = newBall
    instanceCount = instanceCount + 1

    -- window.console:log("clock "..instanceCount)
end

c:addEventListener("mousedown", updateMouse)

local function draw() 
    if instanceCount <= 0 then 
        -- window.console:log("notclock "..instanceCount) 
        window:requestAnimationFrame(draw) 
        return 
    end

    ctx:clearRect(0, 0, c.width, c.height)

    for _, v in ipairs(instances) do
        v:update()
        ctx.fillStyle = "#000000"
        ctx:beginPath()
        ctx:arc(v.vecPos.x, v.vecPos.y, v.properties.radius, 0, 2*math.pi, false) 
        ctx:stroke()
        -- window.console:log()
    end

    time = os.clock()

    window:requestAnimationFrame(draw)

    --document:getElementById("debug").value = "update"
end

draw()