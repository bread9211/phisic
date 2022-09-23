local Vector2 = require "Vector2"

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