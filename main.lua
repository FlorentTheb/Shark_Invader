local Entity = require "entity"
local Player = Entity.Player
local Enemy = Entity.Enemy
local menu = require "menu"
require "Projectile"

local player
local enemies = {}

scene = nil

function love.load()
    scene = "menu"
    menu.init()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    Projectile:init()
    player = Player:create()
    table.insert(enemies, Enemy:create(50, 50))
end

function love.update(dt)
    if scene == "menu" then
        menu.update(dt)
    elseif scene == "game" then
        player:update(enemies, dt)
        for n = #enemies, 1, -1 do
            if enemies[n]:update(player, dt) then
                table.remove(enemies, n)
            end
        end
    end
end

function love.draw()
    if scene == "menu" then
        menu.draw()
    elseif scene == "game" then
        player:draw()
        for n = 1, #enemies do
            enemies[n]:draw()
        end
    end
end

function love.mousepressed(x, y, button)
    if scene == "menu" then
        menu.checkMousePressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if scene == "menu" then
        menu.checkMouseRelease(x, y, button)
    end
end
