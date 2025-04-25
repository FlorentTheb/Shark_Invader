local Entity = require "entity"
local Player = Entity.Player
local Enemy = Entity.Enemy
local Projectile = require "projectile"

local Game = {}

function Game.init()
    Game.currentLevel = 1
    Game.player = Player:create()
    Game.enemies = {}
    Projectile:init()
end

function Game.reset()
    Game.currentLevel = 1
    Game.player:reset()
    Game.enemies = {}
    Projectile:reset()
end

function Game.update(dt)
    Game.player:update(dt)
    if Game.player.hp.current == 0 then
        return "over"
    end
    for n = #Game.enemies, 1, -1 do
        if Game.enemies[n]:update(Game.player, dt) then
            table.remove(Game.enemies, n)
        end
    end
    Projectile:update(Game.player, Game.enemies, dt)
    return
end

function Game.draw()
    Game.player:draw()
    for n = #Game.enemies, 1, -1 do
        Game.enemies[n]:draw()
    end
    Projectile:draw()
end

function Game.loadLevel()
    if Game.currentLevel == 1 then
        table.insert(Game.enemies, Enemy:create(50, 50))
    end
end

return Game
