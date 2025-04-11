Projectile = {}

function Projectile:init()
    self.sprites = {
        big = love.graphics.newImage("__images__/bulle_01.png"),
        small = love.graphics.newImage("__images__/bulle_02.png")
    }
end

function Projectile:create(index)
    local p = {}
    if index == 1 then
        p.sprite = self.sprites.big
        p.damage = 20
    else
        p.sprite = self.sprites.small
        p.damage = 5
    end

    p.position = {x, y}
    p.origin = {x = p.sprite:getWidth() / 2, y = p.sprite:getHeight() / 2}
    p.angle = 0
    p.speed = 400
    p.size = 1
    return p
end

function Projectile.update(projectile, dt)
    projectile.position.x = projectile.position.x + math.cos(projectile.angle) * projectile.speed * dt
    projectile.position.y = projectile.position.y + math.sin(projectile.angle) * projectile.speed * dt

    if projectile.position.x < 0 or projectile.position.x > love.graphics.getWidth() or projectile.position.y < 0 or projectile.position.y > love.graphics.getHeight() then
        return true
    else
        return false
    end
end

function Projectile.draw(projectile)
    love.graphics.draw(projectile.sprite, projectile.position.x, projectile.position.y, projectile.angle, projectile.size, projectile.size, projectile.origin.x, projectile.origin.y)
end
