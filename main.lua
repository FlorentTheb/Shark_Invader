local Entity = require "entity"
local Player = Entity.Player

function love.load()
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    player = Player:create()
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    player:draw()
end
