Projectile = {}

function Projectile:init()
    self.sprites = {
        big = love.graphics.newImage("__images__/bulle_01.png"),
        small = love.graphics.newImage("__images__/bulle_02.png")
    }
    self.projectilesTable = {}
end

function Projectile:create(index, x, y, angle)
    local p = {}
    if index == 1 then
        p.sprite = self.sprites.big
        p.damage = 20
        p.speed = 400
    else
        p.sprite = self.sprites.small
        p.damage = 5
        p.speed = 600
    end
    p.index = index
    p.position = {x = x, y = y}
    p.origin = {x = p.sprite:getWidth() / 2, y = p.sprite:getHeight() / 2}
    p.angle = angle
    p.size = 1

    function p.updatePosition(dt)
        p.position.x = p.position.x + math.cos(p.angle) * p.speed * dt
        p.position.y = p.position.y + math.sin(p.angle) * p.speed * dt
    end

    function p.isHittingEntity()
        if p.index == 1 then -- Big projectile, check the player hitbox
            print(p.position.x, p.position.y)
            if player:isPointInHitbox(p.position.x, p.position.y) then
                if player.hp.current > 0 then
                    player.hp.current = player.hp.current - p.damage
                end
                if player.hp.current < 0 then
                    player.hp.current = 0
                end
                return true
            end
        else -- Small projectile, check the enemies hitboxes
            for n = #enemies, 1, -1 do
                local enemy = enemies[n]
                if enemy:isPointInHitbox(p.position.x, p.position.y) then
                    if enemy.hp.current > 0 then
                        enemy.hp.current = enemy.hp.current - p.damage
                    end
                    if enemy.hp.current <= 0 then
                        table.remove(enemies, n)
                    end
                    return true
                end
            end
        end
        return false
    end

    function p.isOut()
        if p.position.x < 0 or p.position.x > love.graphics.getWidth() or p.position.y < 0 or p.position.y > love.graphics.getHeight() then
            return true
        else
            return false
        end
    end

    function p.draw()
        love.graphics.draw(p.sprite, p.position.x, p.position.y, p.angle, p.size, p.size, p.origin.x, p.origin.y)
    end

    table.insert(self.projectilesTable, p)
end

function Projectile:update(dt)
    if #self.projectilesTable > 0 then
        for n = #self.projectilesTable, 1, -1 do
            local projectile = self.projectilesTable[n]
            projectile.updatePosition(dt)
            if projectile.isHittingEntity() or projectile.isOut() then
                table.remove(self.projectilesTable, n)
            end
        end
    end
end

function Projectile:draw()
    if #self.projectilesTable > 0 then
        for n = 1, #self.projectilesTable do
            self.projectilesTable[n].draw()
        end
    end
end

return Projectile
