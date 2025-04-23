local hitboxChecker = require "utils/hitboxChecker"
local Projectile = require "projectile"

local Entity = {}
Entity.__index = Entity

local currentIndexTurret = 1

local angleComparisonTreshold = 0.01

function Entity:create(x, y, type)
    local e = {}
    e.type = type
    e.body = {
        sprite,
        angle = 0,
        position = {x = x, y = y},
        origin
    }
    e.speedMove = 200
    e.speedRotate = 5
    e.size = 1
    e.projectileTimer = 0
    setmetatable(e, Entity)
    return e
end

function Entity:newProjectile(projectileIndex, dt)
    local projectileX, projectileY, projectileAngle

    if projectileIndex == 1 then
        projectileX = self.canon.tip.x
        projectileY = self.canon.tip.y
        projectileAngle = self.body.angle
    elseif projectileIndex == 2 then
        projectileX = self.turret.positions[self.currentIndexTurret].x
        projectileY = self.turret.positions[self.currentIndexTurret].y
        projectileAngle = self.turret.angle
        self.currentIndexTurret = 3 - self.currentIndexTurret
    else
        return
    end

    if self.projectileTimer > self.projectileTimerTreshold then
        Projectile:create(projectileIndex, projectileX, projectileY, projectileAngle)
        self.projectileTimer = 0
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
    self.body.angle = (self.body.angle + self.speedRotate * dt) % (math.pi * 2)
end

function Entity:turnLeft(dt)
    self.body.angle = (self.body.angle - self.speedRotate * dt) % (math.pi * 2)
    -- On s'assure d'avoir un angle positif (pour des comparaisons d'angle) entre 0 et 2 PI
    if self.body.angle < 0 then
        self.body.angle = math.pi * 2 + self.body.angle
    end
end

function Entity:isPointInHitbox(x, y)
    local hitbox = hitboxChecker.getHitbox(self.body.position, self.body.angle, self.body.sprite:getWidth() * .5, self.body.sprite:getHeight() * .5)
    return hitboxChecker.isIn({x = x, y = y}, hitbox)
end

function Entity:drawHitbox()
    hitboxChecker.drawHitbox(self.body.position, self.body.angle, self.body.sprite:getWidth() * .5, self.body.sprite:getHeight() * .5)
end

function Entity:drawHealth()
    local ratioRemainingHealth = self.hp.current / self.hp.max
    local ratioMissingHealth = 1 - ratioRemainingHealth
    local widthHealthBar = 100
    local heightHealthBar = 10
    local startRemainingHealthX = self.body.position.x - widthHealthBar * .5
    local startRemainingHealthY = self.body.position.y - self.body.sprite:getWidth() * .5 - heightHealthBar
    local startMissingHealthX = startRemainingHealthX + widthHealthBar * ratioRemainingHealth
    love.graphics.push("all")
    love.graphics.setColor({0, 1, 0})
    love.graphics.rectangle("fill", startRemainingHealthX, startRemainingHealthY, widthHealthBar * ratioRemainingHealth, heightHealthBar)
    love.graphics.setColor({1, 0.3, 0.3})
    love.graphics.rectangle("fill", startMissingHealthX, startRemainingHealthY, widthHealthBar * ratioMissingHealth, heightHealthBar)
    love.graphics.setColor({0, 0, 0})
    love.graphics.rectangle("line", startRemainingHealthX, startRemainingHealthY, widthHealthBar, heightHealthBar)

    love.graphics.pop()
end

local Player = {}
setmetatable(Player, {__index = Entity})
Player.__index = Player

function Player:create()
    local p = Entity:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .5, "player")
    p.body.sprite = love.graphics.newImage("__images__/shark_body.png")
    p.body.origin = {x = p.body.sprite:getWidth() / 2 + 2, y = p.body.sprite:getHeight() / 2}
    p.turret = {}
    p.turret.sprite = love.graphics.newImage("__images__/shark_turret.png")
    p.turret.angle = 0
    p.projectileTimerTreshold = 0.1
    p.hp = {
        max = 100,
        current = 100
    }
    p.currentIndexTurret = 1
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

function Player:reset()
    self.body.position.x = love.graphics.getWidth() * .5
    self.body.position.y = love.graphics.getHeight() * .5
    self.smallProjectiles = {}
    self.hp.current = self.hp.max
    self.body.angle = 0
end

function Player:update(dt)
    self.projectileTimer = self.projectileTimer + dt
    self:handleInputs(dt)
    self:updateTurret()
    if self.hp.current == 0 then
        scene = "gameover"
    end
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

    if love.mouse.isDown(1) then
        self:newProjectile(2, dt)
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

function Player:draw()
    love.graphics.draw(self.body.sprite, self.body.position.x, self.body.position.y, self.body.angle, self.size, self.size, self.body.origin.x, self.body.origin.y)
    if self.turret then
        for n = 1, #self.turret.positions do
            love.graphics.draw(self.turret.sprite, self.turret.positions[n].x, self.turret.positions[n].y, self.turret.angle, self.size, self.size, self.turret.origin.x, self.turret.origin.y)
        end
    end
    self:drawHealth()
    self:drawHitbox()
end

local Enemy = {}
setmetatable(Enemy, {__index = Entity})
Enemy.__index = Enemy

function Enemy:create(x, y)
    local e = Entity:create(x, y, "enemy")
    setmetatable(e, Enemy)
    e.body.sprite = love.graphics.newImage("__images__/enemy.png")
    e.body.origin = {x = e.body.sprite:getWidth() / 2, y = e.body.sprite:getHeight() / 2}
    e.hp = {
        max = 100,
        current = 100
    }
    e.deltaPatroling = 0
    e.patroling = {
        isTurning = false,
        deltaAction = .5,
        currentTime = 0,
        turnDirection = 1
    }
    e.color = {1, 1, 1, 1}
    e.projectileTimerTreshold = 0.3
    e.canon = {
        length = 39,
        tip = {}
    }
    e.speedMove = 50
    e.speedRotate = 2
    e.state = "patroling"
    e.states = {
        patroling = function(dt) e:patrol(dt) end,
        chasing   = function(dt) e:chase(dt) end,
        firing    = function(dt) e:fire(dt) end,
        fleeing   = function(dt) e:flee(dt) end,
    }
    return e
end

function Enemy:draw()
    love.graphics.push("all")
    love.graphics.setColor(self.color)
    love.graphics.draw(self.body.sprite, self.body.position.x, self.body.position.y, self.body.angle, self.size, self.size, self.body.origin.x, self.body.origin.y)
    love.graphics.pop()
    self:drawHealth()
    --self:drawHitbox()
end

function Enemy:update(dt)
    if self.state == "patroling" then
        self.color = {1, 1, 1, 1}
    elseif self.state == "chasing" then
        self.color = {1, 1, .7, 1}
    elseif self.state == "firing" then
        self.color = {1, .7, .7, 1}
    elseif self.state == "fleeing" then
        self.color = {.7, .7, 1, 1}
    end
    self.projectileTimer = self.projectileTimer + dt
    self.canon.tip.x = self.body.position.x + math.cos(self.body.angle) * self.canon.length
    self.canon.tip.y = self.body.position.y + math.sin(self.body.angle) * self.canon.length
    self:updateState()
    if self.states[self.state] then
        self.states[self.state](dt)
    end
    return self.hp.current == 0
end

function Enemy:updateState()
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    if squaredDist >= 600 * 600 then
        self.state = "patroling"
    elseif squaredDist < 600 * 600 and squaredDist >= 400 * 400 then
        self.state = "chasing"
    elseif squaredDist < 400 * 400 and squaredDist >= 200 * 200 then
        self.state = "firing"
    elseif squaredDist < 200 * 200 then
        self.state = "fleeing"
    end
end

function Enemy:patrol(dt)
    if self.patroling.currentTime == 0 then
        self.patroling.isTurning = math.random() > .5
        self.patroling.turnDirection = math.random(2)
    end
    if self.patroling.isTurning then
        if self.patroling.turnDirection == 1 then
            self:turnLeft(dt)
        else
            self:turnRight(dt)
        end
    end
    self:move(dt, 1)
    self.patroling.currentTime = self.patroling.currentTime + dt
    if self.patroling.currentTime > self.patroling.deltaAction then
        self.patroling.currentTime = 0
    end
end

function Enemy:chase(dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local angleTarget = (math.atan2(dY, dX)) % (2 * math.pi)
    local diff = (angleTarget - self.body.angle + math.pi) % (2 * math.pi) - math.pi
    if math.abs(diff) > angleComparisonTreshold then
        if diff > 0 then
            self:turnRight(dt)
        else
            self:turnLeft(dt)
        end
    end
    self:move(dt, 1)
end

function Enemy:fire(dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    self.body.angle = math.atan2(dY, dX)
    self:newProjectile(1, dt)
end

function Enemy:flee(dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    self.body.angle = math.atan2(dY, dX) + math.pi
    self:move(dt, 1)
end

return {Player = Player, Enemy = Enemy}
