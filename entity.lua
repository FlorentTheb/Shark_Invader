local Entity = {}
Entity.__index = Entity

local bigP_treshold = 0.3
local smallP_treshold = 0.1
local currentIndexTurret = 1

function Entity:create(x, y)
    local e = {}
    e.angle = 0
    e.speedMove = 200
    e.speedRotate = 5
    e.state = {isFiring = false}
    e.position = {x = x, y = y}
    e.angle = 0
    e.size = 1
    e.deltaB = 0
    e.deltaS = 0
    e.canon = {
        length = 39,
        tip = {}
    }
    e.smallProjectiles = {}
    e.bigProjectiles = {}
    setmetatable(e, Entity)
    return e
end

function Entity:updateProjectiles(dt)
    if self.bigProjectiles then
        for n = #self.bigProjectiles, 1, -1 do
            if Projectile.update(self.bigProjectiles[n], dt) then
                table.remove(self.bigProjectiles, n)
            end
        end
    end

    if self.smallProjectiles then
        for n = #self.smallProjectiles, 1, -1 do
            if Projectile.update(self.smallProjectiles[n], dt) then
                table.remove(self.smallProjectiles, n)
            end
        end
    end
end

function Entity:drawProjectiles()
    if self.bigProjectiles then
        for n = #self.bigProjectiles, 1, -1 do
            Projectile.draw(self.bigProjectiles[n])
        end
    end

    if self.smallProjectiles then
        for n = #self.smallProjectiles, 1, -1 do
            Projectile.draw(self.smallProjectiles[n])
        end
    end
end

function Entity:addBigProjectile(projectile, dt)
    projectile.position.x = self.canon.tip.x
    projectile.position.y = self.canon.tip.y
    projectile.angle = self.angle
    self.deltaB = self.deltaB + dt
    if self.deltaB > bigP_treshold or #self.bigProjectiles == 0 then
        table.insert(self.bigProjectiles, projectile)
        self.deltaB = 0
    end
end

function Entity:addSmallProjectile(projectile, dt)
    self.deltaS = self.deltaS + dt
    if self.deltaS > smallP_treshold or #self.smallProjectiles == 0 then
        projectile.position.x = self.turrets[currentIndexTurret].position.x
        projectile.position.y = self.turrets[currentIndexTurret].position.y
        projectile.angle = self.turrets[currentIndexTurret].angle
        table.insert(self.smallProjectiles, projectile)
        self.deltaS = 0
        currentIndexTurret = 3 - currentIndexTurret
    end
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
    self.canon.tip.x = self.position.x + math.cos(self.angle) * self.canon.length
    self.canon.tip.y = self.position.y + math.sin(self.angle) * self.canon.length
    self:updateTurret()
    self:updateProjectiles(dt)
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
    self:drawProjectiles()
end

local Enemy = {}
setmetatable(Enemy, {__index = Entity})
Enemy.__index = Enemy

function Enemy:create(x, y)
    local e = Entity:create(x, y)
    e.sprite = love.graphics.newImage("__images__/enemy.png")
    e.origin = {x = e.sprite:getWidth() / 2, y = e.sprite:getHeight() / 2}
    e.health = 100
    e.deltaPatroling = 0
    e.patroling = {
        isTurning = false,
        isMoving = true,
        deltaAction = .5,
        currentTime = 0,
        turnDirection = 1
    }
    e.speedMove = 50
    e.speedRotate = 2
    e.state = {isIDLE = true, isPatroling = false, isChasing = false, isFiring = false, isFleeing = false}
    setmetatable(e, Enemy)
    return e
end

function Enemy:draw()
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.size, self.size, self.origin.x, self.origin.y)
end

function Enemy:update(player, dt)
    local pX = player.position.x
    local pY = player.position.y
    self.canon.tip.x = self.position.x + math.cos(self.angle) * self.canon.length
    self.canon.tip.y = self.position.y + math.sin(self.angle) * self.canon.length
    self:behave(dt)
end

function Enemy:behave(dt)
    if self.patroling.currentTime == 0 then
        self.patroling.isTurning = math.random() > .5
    end
    if self.patroling.isTurning then
        if self.patroling.currentTime == 0 then
            self.patroling.turnDirection = math.random(2)
        end
        if self.patroling.turnDirection == 1 then
            self:turnLeft(dt)
        else
            self:turnRight(dt)
        end
    end
    if self.patroling.isMoving then
        self:move(dt, 1)
    end
    self.patroling.currentTime = self.patroling.currentTime + dt
    if self.patroling.currentTime > self.patroling.deltaAction then
        self.patroling.currentTime = 0
    end
end

return {Player = Player, Enemy = Enemy}
