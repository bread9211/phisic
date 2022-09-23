local window = js.global
local document = window.document
local c = document:getElementById("screen")
local ctx = c:getContext("2d")

-- local ball = require "ball"
local spawnType = "ball"

local instances = {}
local instanceCount = 0

local time = os.clock()

local Vector2 = {}
Vector2.__index = Vector2

local Ball = {}
Ball.__index = Ball

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
function Ball:new(x, y, density, radius)
    local o = {}
    setmetatable(o, self)

    self.vecPos = Vector2:new(x, y)
    self.vecVel = Vector2:new(0, 0)
    self.vecAcc = Vector2:new(0, 0)
    self.properties = {
        density = density,
        radius = radius,
        airDrag = 0.99,
        elasticity = 0.8,
        groundFriction = 0.98,
    }

    self.lastUpdate = 0

    return o
end

function Ball:update()
    self.vecPos.x = self.vecPos.x + self.vecVel.x
    self.vecPos.y = self.vecPos.y + self.vecVel.y

    if (self.vecPos.y >= c.height - self.properties.radius) then
        self.vecPos.y = c.height - self.properties.radius
        self.vecVel.y = -(self.vecVel.y * self.properties.elasticity)
    end

    if (self.vecPos.x >= c.width - self.properties.radius) or (self.vecPos.x <= self.properties.radius) then
        self.vecPos.x = self.properties.radius and (self.vecPos.x < c.width + self.properties.radius) or (c.width - self.properties.radius)
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
    -- document:getElementById("debug").value = instanceCount .. spawnType
    local x = e.clientX - rect.left
    -- document:getElementById("debug").value = x
    local y = e.clientY - rect.top
    -- document:getElementById("debug").value = x .. y

    local newBall = Ball:new(x, y, 1, math.random(5,15))
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