local Entity = require "entity"
local Player = Entity.Player

function love.load()
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    player = Player:create()
end

function love.update(dt)
    handleKeyboard(dt)
    player:update(dt)
end

function love.draw()
    player:draw()
end

function handleKeyboard(dt)
    if love.keyboard.isDown("z") then
        player:move(dt, 1)
    elseif love.keyboard.isDown("s") then
        player:move(dt, -1)
    end

    if love.keyboard.isDown("q") then
        player:turnLeft(dt)
    elseif love.keyboard.isDown("d") then
        player:turnRight(dt)
    end

    if love.keyboard.isDown("space") then
        player:addBigProjectile(Projectile:create(1), dt)
    end
end
