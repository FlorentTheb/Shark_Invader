Entity = require "entity"
Player = Entity.Player
Enemy = Entity.Enemy
local Menu = require "menu"
local GameOver = require "gameOver"
require "Projectile"

player = nil
enemies = {}

scene = nil

function love.load()
    scene = "menu"
    Menu.init()
    GameOver.init()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    Projectile:init()
    player = Player:create()
end

function love.update(dt)
    if scene == "menu" then
        Menu.update(dt)
    elseif scene == "game" then
        player:update(enemies, dt)
        for n = #enemies, 1, -1 do
            if enemies[n]:update(player, dt) then
                table.remove(enemies, n)
            end
        end
    elseif scene == "gameover" then
        GameOver.update(dt)
    end
end

function love.draw()
    if scene == "menu" then
        Menu.draw()
    elseif scene == "game" then
        player:draw()
        for n = 1, #enemies do
            enemies[n]:draw()
        end
    elseif scene == "gameover" then
        GameOver.draw()
    end
end

function love.mousepressed(x, y, button)
    if scene == "menu" and button == 1 then
        Menu.checkMousePressed()
    elseif scene == "gameover" and button == 1 then
        GameOver.checkMousePressed()
    end
end

function love.mousereleased(x, y, button)
    if scene == "menu" and button == 1 then
        Menu.checkMouseRelease()
    elseif scene == "gameover" and button == 1 then
        GameOver.checkMouseRelease()
    end
end
