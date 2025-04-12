local Entity = {}
Entity.__index = Entity

local bigP_treshold = 0.3
local smallP_treshold = 0.1
local currentIndexTurret = 1

function Entity:create(x, y)
    local e = {}
    e.body = {
        sprite,
        angle = 0,
        position = {x = x, y = y},
        origin
    }
    e.angle = 0
    e.speedMove = 200
    e.speedRotate = 5
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
    projectile.angle = self.body.angle
    self.deltaB = self.deltaB + dt
    if self.deltaB > bigP_treshold or #self.bigProjectiles == 0 then
        table.insert(self.bigProjectiles, projectile)
        self.deltaB = 0
    end
end

function Entity:addSmallProjectile(projectile, dt)
    self.deltaS = self.deltaS + dt
    if self.deltaS > smallP_treshold or #self.smallProjectiles == 0 then
        projectile.position.x = self.turret.positions[currentIndexTurret].x
        projectile.position.y = self.turret.positions[currentIndexTurret].y
        projectile.angle = self.turret.angle
        table.insert(self.smallProjectiles, projectile)
        self.deltaS = 0
        currentIndexTurret = 3 - currentIndexTurret
    end
end

function Entity:move(dt, v)
    if self.body.position.x > 0 and self.body.position.x < love.graphics.getWidth() then
        self.body.position.x = self.body.position.x + math.cos(self.body.angle) * v * self.speedMove * dt
    elseif self.body.position.x <= 0 then
        self.body.position.x = 1
    else
        self.body.position.x = love.graphics.getWidth() - 1
    end

    if self.body.position.y > 0 and self.body.position.y < love.graphics.getHeight() then
        self.body.position.y = self.body.position.y + math.sin(self.body.angle) * v * self.speedMove * dt
    elseif self.body.position.y <= 0 then
        self.body.position.y = 1
    else
        self.body.position.y = love.graphics.getHeight() - 1
    end
end

function Entity:turnRight(dt)
    self.body.angle = self.body.angle + self.speedRotate * dt
end

function Entity:turnLeft(dt)
    self.body.angle = self.body.angle - self.speedRotate * dt
end

function Entity:draw()
    love.graphics.draw(self.body.sprite, self.body.position.x, self.body.position.y, self.body.angle, self.size, self.size, self.body.origin.x, self.body.origin.y)
    if self.turret then
        for n = 1, #self.turret.positions do
            love.graphics.draw(self.turret.sprite, self.turret.positions[n].x, self.turret.positions[n].y, self.turret.angle, self.size, self.size, self.turret.origin.x, self.turret.origin.y)
        end
    end
    self:drawProjectiles()
end

local Player = {}
setmetatable(Player, {__index = Entity})
Player.__index = Player

function Player:create()
    local p = Entity:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .5)
    p.body.sprite = love.graphics.newImage("__images__/shark_body.png")
    p.body.origin = {x = p.body.sprite:getWidth() / 2, y = p.body.sprite:getHeight() / 2}
    p.turret = {}
    p.turret.sprite = love.graphics.newImage("__images__/shark_turret.png")
    p.turret.angle = 0
    p.turret.origin = {
        x = p.turret.sprite:getWidth() / 2,
        y = p.turret.sprite:getHeight() / 2
    }
    p.turret.positions = {
        {x = p.body.position.x, y = p.body.position.y},
        {x = p.body.position.x, y = p.body.position.y}
    }
    p.turret.tips = {
        {x = p.body.position.x, y = p.body.position.y},
        {x = p.body.position.x, y = p.body.position.y}
    }
    setmetatable(p, Player)
    return p
end

function Player:update(dt)
    self.canon.tip.x = self.body.position.x + math.cos(self.body.angle) * self.canon.length
    self.canon.tip.y = self.body.position.y + math.sin(self.body.angle) * self.canon.length
    self:handleInputs(dt)
    self:updateTurret()
    self:updateProjectiles(dt)
end

function Player:handleInputs(dt)
    if love.keyboard.isDown("z") then
        self:move(dt, 1)
    elseif love.keyboard.isDown("s") then
        self:move(dt, -1)
    end

    if love.keyboard.isDown("q") then
        self:turnLeft(dt)
    elseif love.keyboard.isDown("d") then
        self:turnRight(dt)
    end

    if love.keyboard.isDown("space") then
        self:addBigProjectile(Projectile:create(1), dt)
    end

    if love.mouse.isDown(1) then
        self:addSmallProjectile(Projectile:create(2), dt)
    end
end

function Player:updateTurret()
    local mX, mY = love.mouse.getPosition()
    for n = 1, #self.turret.positions do
        self.turret.angle = math.atan2(mY - self.body.position.y, mX - self.body.position.x)
        self.turret.positions[n].x = self.body.position.x + math.cos(self.turret.angle + math.pi * (1.5 - n)) * 8 * self.size
        self.turret.positions[n].y = self.body.position.y + math.sin(self.turret.angle + math.pi * (1.5 - n)) * 8 * self.size

        self.turret.tips[n].x = self.turret.positions[n].x + math.cos(self.turret.angle) * 12 * self.size
        self.turret.tips[n].y = self.turret.positions[n].y + math.sin(self.turret.angle) * 12 * self.size
    end
end

local Enemy = {}
setmetatable(Enemy, {__index = Entity})
Enemy.__index = Enemy

function Enemy:create(x, y)
    local e = Entity:create(x, y)
    e.body.sprite = love.graphics.newImage("__images__/enemy.png")
    e.body.origin = {x = e.body.sprite:getWidth() / 2, y = e.body.sprite:getHeight() / 2}
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

function Enemy:update(player, dt)
    self.canon.tip.x = self.body.position.x + math.cos(self.body.angle) * self.canon.length
    self.canon.tip.y = self.body.position.y + math.sin(self.body.angle) * self.canon.length
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
