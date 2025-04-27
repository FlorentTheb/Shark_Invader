Projectile = {}

function Projectile.new()
    Projectile.sprites = {
        big = love.graphics.newImage("assets/__images__/bulle_01.png"),
        small = love.graphics.newImage("assets/__images__/bulle_02.png")
    }
end

function Projectile.init()
    Projectile.projectilesTable = {}
end

function Projectile.create(index, x, y, angle) -- index helps to indicate if its shot from an enemy or the player. Needed for the check of hitboxes
    local p = {}
    if index == 1 then
        p.sprite = Projectile.sprites.big
        p.damage = 20
        p.speed = 400
    else
        p.sprite = Projectile.sprites.small
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

    function p.isHittingEntity(player, enemies)
        if p.index == 1 then -- Big projectile, check the player hitbox
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
                    elseif enemy.hp.current < 0 then
                        enemy.hp.current = 0
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

    function p.update(player, enemies, dt)
        p.updatePosition(dt)
        if p.isOut() then
            return true
        end
        if player and enemies and p.isHittingEntity(player, enemies) then
            return true
        else
            return false
        end
    end

    SoundManager.bubble[index]:stop()
    SoundManager.bubble[index]:play()

    table.insert(Projectile.projectilesTable, p)
end

return Projectile
