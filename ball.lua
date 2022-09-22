local Vector2 = require "Vector2"

local Ball = {}
Ball.__index = Ball

function Ball:new()
    local o = {}
    setmetatable(0, self)

    self.vecPos = Vector2:new()
    self.vecVel = Vector2:new()
    self.vecAcc = Vector2:new()
    self.properties = {
        density = 1,
        radius = 1,
        airResist = 1,
    }

    self.lastUpdate = 0

    return o
end

function Ball:update(t)
    local dT = t - self.lastUpdate

    local mass = self.properties.density * math.pi*self.properties.radius^2

    local vecPosX = self.vecVel.x*dT + (self.vecAcc.x*dT^2)/2
    local vecPosY = self.vecVel.y*dT + (self.vecAcc.y*dT^2)/2

    local vecVelX = self.vecVel.x + self.vecAcc.x*dT
    local vecVelY = self.vecVel.y + self.vecAcc.y*dT

    local vecAccX
    local vecAccY
end