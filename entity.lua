local Entity = {}
Entity.__index = Entity

function Entity:create(x, y)
    local e = {}
    e.angle = 0
    e.speedMove = 200
    e.speedRotate = 5
    e.state = {isFiring = false}
    e.position = {x = x, y = y}
    e.angle = 0
    e.size = 1
    e.canon = {
        length = 39,
        tip = {}
    }
    setmetatable(e, Entity)
    return e
end

function Entity:move(dt, v)
    if self.position.x > 0 and self.position.x < love.graphics.getWidth() then
        self.position.x = self.position.x + math.cos(self.angle) * v * self.speedMove * dt
    elseif self.position.x <= 0 then
        self.position.x = 1
    else
        self.position.x = love.graphics.getWidth() - 1
    end

    if self.position.y > 0 and self.position.y < love.graphics.getHeight() then
        self.position.y = self.position.y + math.sin(self.angle) * v * self.speedMove * dt
    elseif self.position.y <= 0 then
        self.position.y = 1
    else
        self.position.y = love.graphics.getHeight() - 1
    end
end

function Entity:turnRight(dt)
    self.angle = self.angle + self.speedRotate * dt
end

function Entity:turnLeft(dt)
    self.angle = self.angle - self.speedRotate * dt
end

local Player = {}
setmetatable(Player, {__index = Entity})
Player.__index = Player

function Player:create()
    local screenX = love.graphics.getWidth() * .5
    local screenY = love.graphics.getHeight() * .5
    local p = Entity:create(screenX, screenY)
    p.sprites = {body = love.graphics.newImage("__images__/shark_body.png"), turret = love.graphics.newImage("__images__/shark_turret.png")}
    p.origin = {x = p.sprites.body:getWidth() / 2, y = p.sprites.body:getHeight() / 2}
    p.turrets = {
        {
            position = {x = p.position.x, y = p.position.y},
            origin = {x = p.sprites.turret:getWidth() / 2, y = p.sprites.turret:getHeight() / 2},
            angle = 0,
            tip = {x = p.position.x, y = p.position.y}
        },
        {
            position = {x = p.position.x, y = p.position.y},
            origin = {x = p.sprites.turret:getWidth() / 2, y = p.sprites.turret:getHeight() / 2},
            angle = 0,
            tip = {x = p.position.x, y = p.position.y}
        }
    }
    setmetatable(p, Player)
    return p
end

function Player:update(dt)
    self:updateTurret()
end

function Player:updateTurret()
    local mX, mY = love.mouse.getPosition()
    for n = 1, #self.turrets do
        self.turrets[n].angle = math.atan2(mY - self.position.y, mX - self.position.x)
        self.turrets[n].position.x = self.position.x + math.cos(self.turrets[n].angle + math.pi * (1.5 - n)) * 8 * self.size
        self.turrets[n].position.y = self.position.y + math.sin(self.turrets[n].angle + math.pi * (1.5 - n)) * 8 * self.size

        self.turrets[n].tip.x = self.turrets[n].position.x + math.cos(self.turrets[n].angle) * 12 * self.size
        self.turrets[n].tip.y = self.turrets[n].position.y + math.sin(self.turrets[n].angle) * 12 * self.size
    end
end

function Player:draw()
    love.graphics.draw(self.sprites.body, self.position.x, self.position.y, self.angle, self.size, self.size, self.origin.x, self.origin.y)
    for n = 1, #self.turrets do
        love.graphics.draw(self.sprites.turret, self.turrets[n].position.x, self.turrets[n].position.y, self.turrets[n].angle, self.size, self.size, self.turrets[n].origin.x, self.turrets[n].origin.y)
    end
end

return {Player = Player}
