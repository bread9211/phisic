local window = js.global
local document = window.document
local c = document:getElementById("screen")
local ctx = c:getContext("2d")

-- local ball = require "ball"
local spawnType = "ball"

local instances = {}
local instanceCount = 0

local gravity = 0.98

-- local time = os.clock()
-- local checked = {}

local Vector2 = {}
Vector2.__index = Vector2

local Ball = {}
local BallMT = {__index = Ball}

local Bomb = {}
local BombMT = {__index = Bomb}

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

    -- ignore
    o.Unit = function ()
        return Vector2:new(o.x/o.Magnitude(), o.y/o.Magnitude())
    end

    o.Dot = function (v)
        return (o.x*v.x) + (o.y*v.y)
    end
    
    mt.__add = function (a, b)
        return Vector2:new(a.x+b.x, a.y+b.y)
    end
    mt.__sub = function (a, b)
        return Vector2:new(a.x-b.x, a.y-b.y)
    end
    mt.__mul = function (a, b)
        return Vector2:new(a.x*b, a.y*b)
    end
    mt.__div = function (a, b)
        return Vector2:new(a.x/b, a.y/b)
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
        mass = density*(math.pi*(radius^2))
    }

    -- ignore
    self.lastUpdate = 0
    self.lowerBound = c.height-self.properties.radius
    self.oldPos = Vector2:new(0, 0)

    return setmetatable(self, BallMT)
end

function Ball:update()
    for _, v in ipairs(instances) do
        local collision = self.vecPos - v.vecPos
        local distance = collision.Magnitude()
        local radii = self.properties.radius+v.properties.radius

        if (collision.Dot(collision) > radii^2) and (self ~= v) then goto next end

        local moveVec

        if (distance ~= 0) then
            moveVec = collision*((radii-distance)/distance)
        else
            distance = radii-1
            collision = Vector2:new(radii, 0)
            moveVec = collision*((radii-distance)/distance)
        end

        if (self.vecPos.x == v.vecPos.x) and not (self == v) then
            self.lowerBound = v.vecPos.y - v.properties.radius
        else 
            self.lowerBound = c.height-self.properties.radius
        end

        self.vecPos = self.vecPos + (moveVec*(self.properties.mass/(self.properties.mass+v.properties.mass)))
        v.vecPos = v.vecPos - (moveVec*(v.properties.mass/(self.properties.mass+v.properties.mass)))
        
        collision = collision / distance
        local aci = self.vecVel.Dot(collision)
        local bci = v.vecVel.Dot(collision)

        local acf = bci
        local bcf = aci

        self.vecVel.x = self.vecVel.x + (acf-aci)*collision.x
        self.vecVel.y = self.vecVel.y + (acf-aci)*collision.y
        v.vecVel.x = v.vecVel.x + (bcf-bci)*collision.x
        v.vecVel.y = v.vecVel.y + (bcf-bci)*collision.y

        ::next::
    end

    self.vecPos.x = self.vecPos.x + self.vecVel.x
    self.vecPos.y = self.vecPos.y + self.vecVel.y

    if (self.vecPos.y >= self.lowerBound) then
        self.vecPos.y = self.lowerBound
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

    if (self.lowerBound == c.height-self.properties.radius) then
        self.vecVel.y = self.vecVel.y + gravity
    end
    self.vecVel.x = self.vecVel.x * self.properties.airDrag
    self.vecVel.y = self.vecVel.y * self.properties.airDrag
    if (self.vecPos.y >= (c.height - self.properties.radius)) then
        self.vecVel.x = self.vecVel.x * self.properties.groundFriction;
    end
end

function Bomb:new(x, y, strength, radius, decay)
    local self = {}

    self.vecPos = Vector2:new(x, y)
    self.strength = strength
    self.radius = radius
    self.decay = decay

    return setmetatable(self,BombMT)
end

function Bomb:Detonate()
    for _, v in ipairs(instances) do
        local direction = self.vecPos-v.vecPos
        local distance = (direction).Magnitude()

        if (distance <= self.radius) then
            v.vecVel = direction.Unit()*-1 + v.vecVel*(self.strength+1)
        else
            distance = distance - self.radius
            
            coroutine.wrap(function ()
                local function wait(n)
                    local last = os.clock()

                    while (n < (os.clock()-last)) do end
                end

                wait()
                v.vecVel = direction.Unit()*-1 + v.vecVel*(self.strength*(1/distance))
            end)
        end
    end
end

document:getElementById("balls"):addEventListener("click", function ()
    document:getElementById("bombInp").style.visibility = "hidden"

    spawnType = "ball"
end)

document:getElementById("bombs"):addEventListener("click", function ()
    document:getElementById("bombInp").style.visibility = "visible"

    spawnType = "bomb"
end)

document:getElementById("gravity"):addEventListener("input", function ()
    gravity = tonumber(document:getElementById("gravity").value)
end)

local function updateMouse(_, e)
    local rect = c:getBoundingClientRect()
    local x = e.clientX - rect.left
    local y = e.clientY - rect.top

    if (spawnType == "ball") then
        local newBall = Ball:new(x, y, 1, 5, 0.99, 0.5, 0.98)
        instances[instanceCount+1] = newBall
        instanceCount = instanceCount + 1
    elseif (spawnType == "bomb") then
        Bomb:new(x, y, tonumber(document:getElementById("strength").value), tonumber(document:getElementById("radius").value), tonumber(document:getElementById("decay").value)):Detonate()
    end

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

    window:requestAnimationFrame(draw)

    --document:getElementById("debug").value = "update"
end

draw()