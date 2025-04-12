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
    table.insert(enemies, Enemy:create(500, 500))
end

function love.update(dt)
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