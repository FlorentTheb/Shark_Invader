local Entity = require "entity"
local Player = Entity.Player
local Enemy = Entity.Enemy
require "Projectile"

local player
local enemies = {}

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    Projectile:init()
    player = Player:create()
    table.insert(enemies, Enemy:create(50, 50))
end

function love.update(dt)
    handleKeyboard(dt)
    handleMouse(dt)
    player:update(dt)
    for n = 1, #enemies do
        enemies[n]:update(player, dt)
    end
end

function love.draw()
    player:draw()
    for n = 1, #enemies do
        enemies[n]:draw()
    end
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

function handleMouse(dt)
    if love.mouse.isDown(1) then
        player:addSmallProjectile(Projectile:create(2), dt)
    end
end
