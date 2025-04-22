local Entity = {}
Entity.__index = Entity

local bigP_treshold = 0.3
local smallP_treshold = 0.1
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

function Entity:updateProjectiles(entity, dt)
    if self.bigProjectiles then
        for n = #self.bigProjectiles, 1, -1 do
            if Projectile.update(entity, self.bigProjectiles[n], dt) then
                table.remove(self.bigProjectiles, n)
            end
        end
    end

    if self.smallProjectiles then
        for n = #self.smallProjectiles, 1, -1 do
            if Projectile.update(entity, self.smallProjectiles[n], dt) then
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
    -- On va check si le point est du même côté des 4 segments de la hitbox (produit vectoriel)
    local hitbox = {
        {
            x = self.body.position.x - math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.cos(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y - math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.sin(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x + math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.cos(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y + math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.sin(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x + math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.cos(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y + math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.sin(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x - math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.cos(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y - math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.sin(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5
        }
    }

    local refSign  -- signe d'un coté

    for i = 1, #hitbox do
        local a = hitbox[i]
        local b = hitbox[(i % 4) + 1]

        local AB = {
            -- Vecteur du côté que l'on check
            x = b.x - a.x,
            y = b.y - a.y
        }
        local APoint = {
            -- Vecteur depuis le coin actuel jusqu'au point à check
            x = x - a.x,
            y = y - a.y
        }
        local prodVec = AB.x * APoint.y - AB.y * APoint.x

        if i == 1 then
            refSign = prodVec > 0 and 1 or -1
        else
            if (prodVec > 0 and refSign < 0) or (prodVec < 0 and refSign > 0) then
                return false -- Dès que l'on a un des produits vectoriels différents d'un autre, on sait que l'on sera en dehors de la hitbox
            end
        end
    end

    return true -- Tous les produits vectoriels ont le même signe : on est à l'intérieur du rectangle
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

function Entity:drawHitbox()
    local hitbox = {
        {
            x = self.body.position.x - math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.cos(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y - math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.sin(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x + math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.cos(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y + math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.sin(self.body.angle - math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x + math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.cos(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y + math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 - 2) + math.sin(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5
        },
        {
            x = self.body.position.x - math.cos(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.cos(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5,
            y = self.body.position.y - math.sin(self.body.angle) * (self.body.sprite:getWidth() * .5 + 2) + math.sin(self.body.angle + math.pi * .5) * self.body.sprite:getHeight() * .5
        }
    }

    love.graphics.polygon("line", hitbox[1].x, hitbox[1].y, hitbox[2].x, hitbox[2].y, hitbox[3].x, hitbox[3].y, hitbox[4].x, hitbox[4].y)
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
    p.hp = {
        max = 100,
        current = 100
    }
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

function Player:update(enemies, dt)
    self.canon.tip.x = self.body.position.x + math.cos(self.body.angle) * self.canon.length
    self.canon.tip.y = self.body.position.y + math.sin(self.body.angle) * self.canon.length
    self:handleInputs(dt)
    self:updateTurret()
    self:updateProjectiles(enemies, dt)
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

function Player:draw()
    love.graphics.draw(self.body.sprite, self.body.position.x, self.body.position.y, self.body.angle, self.size, self.size, self.body.origin.x, self.body.origin.y)
    if self.turret then
        for n = 1, #self.turret.positions do
            love.graphics.draw(self.turret.sprite, self.turret.positions[n].x, self.turret.positions[n].y, self.turret.angle, self.size, self.size, self.turret.origin.x, self.turret.origin.y)
        end
    end
    self:drawProjectiles()
    self:drawHealth()
    local startHitboxX = self.body.position.x - self.body.sprite:getWidth() * .5
    local startHitboxY = self.body.position.y - self.body.sprite:getHeight() * .5
    love.graphics.circle("line", self.body.position.x, self.body.position.y, 200)
    love.graphics.circle("line", self.body.position.x, self.body.position.y, 400)
    love.graphics.circle("line", self.body.position.x, self.body.position.y, 600)
    self:drawHitbox()
end

local Enemy = {}
setmetatable(Enemy, {__index = Entity})
Enemy.__index = Enemy

function Enemy:create(x, y)
    local e = Entity:create(x, y, "enemy")
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
    e.speedMove = 50
    e.speedRotate = 2
    e.state = {isPatroling = true, isChasing = false, isFiring = false, isFleeing = false}
    setmetatable(e, Enemy)
    return e
end

function Enemy:draw()
    love.graphics.push("all")
    if self.state.isPatroling then
        love.graphics.setColor({1, 1, 1})
    elseif self.state.isChasing then
        love.graphics.setColor({1, 1, 0.7})
    elseif self.state.isFiring then
        love.graphics.setColor({1, 0.7, 0.7})
    elseif self.state.isFleeing then
        love.graphics.setColor({0.7, 0.7, 1})
    end
    love.graphics.draw(self.body.sprite, self.body.position.x, self.body.position.y, self.body.angle, self.size, self.size, self.body.origin.x, self.body.origin.y)
    love.graphics.pop()
    self:drawProjectiles()
    self:drawHealth()
    self:drawHitbox()
end

function Enemy:update(player, dt)
    self.canon.tip.x = self.body.position.x + math.cos(self.body.angle) * self.canon.length
    self.canon.tip.y = self.body.position.y + math.sin(self.body.angle) * self.canon.length
    self:updateState(player, dt)
    self:behave(player, dt)
    self:updateProjectiles(player, dt)
    return self.hp.current == 0
end

function Enemy:updateState(player, dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    if squaredDist >= 600 * 600 then
        self.state = {
            isPatroling = true,
            isChasing = false,
            isFiring = false,
            isFleeing = false
        }
    elseif squaredDist < 600 * 600 and squaredDist >= 400 * 400 then
        self.state = {
            isPatroling = false,
            isChasing = true,
            isFiring = false,
            isFleeing = false
        }
    elseif squaredDist < 400 * 400 and squaredDist >= 200 * 200 then
        self.state = {
            isPatroling = false,
            isChasing = false,
            isFiring = true,
            isFleeing = false
        }
    elseif squaredDist < 200 * 200 then
        self.state = {
            isPatroling = false,
            isChasing = false,
            isFiring = false,
            isFleeing = true
        }
    end
end

function Enemy:behave(player, dt)
    if self.state.isPatroling then
        self:patrol(dt)
    elseif self.state.isChasing then
        self:chase(player, dt)
    elseif self.state.isFiring then
        self:fire(player, dt)
    elseif self.state.isFleeing then
        self:flee(player, dt)
    end
end

function Enemy:patrol(dt)
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
    self:move(dt, 1)
    self.patroling.currentTime = self.patroling.currentTime + dt
    if self.patroling.currentTime > self.patroling.deltaAction then
        self.patroling.currentTime = 0
    end
end

function Enemy:chase(player, dt)
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

function Enemy:fire(player, dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    self.body.angle = math.atan2(dY, dX)
    self:addBigProjectile(Projectile:create(1), dt)
end

function Enemy:flee(player, dt)
    local pX = player.body.position.x
    local pY = player.body.position.y
    local dX = pX - self.body.position.x
    local dY = pY - self.body.position.y
    local squaredDist = dX * dX + dY * dY
    self.body.angle = math.atan2(dY, dX) + math.pi
    self:move(dt, 1)
end

return {Player = Player, Enemy = Enemy}
