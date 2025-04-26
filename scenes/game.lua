local Entity = require "objects/entity"
local Player = Entity.Player
local Enemy = Entity.Enemy
local Projectile = require "objects/projectile"
local NextLevel = require "utils/nextLevel"

local Game = {}

function Game.new()
    Projectile.new()
    Game.player = Player:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .5)
    Game.enemies = {}
    Game.currentLevel = 1
end

function Game.init()
    NextLevel.init()
    Projectile.init()
    Game.projectiles = Projectile.projectilesTable
    Game.player.body.position.x = love.graphics.getWidth()
    Game.player.body.position.y = love.graphics.getHeight() * .5
    Game.player.body.angle = math.pi
    Game.roundStarting = true
    Game.roundOver = false
    Game.loadLevel()
end

function Game.reset()
    Game.player.hp.current = Game.player.hp.max
    Game.enemies = {}
    Game.projectiles = {}
    Game.currentLevel = 1
end

function Game.updateEnemies(dt)
    for n = #Game.enemies, 1, -1 do
        Game.enemies[n]:update(Game.player, dt)
        if Game.enemies[n].hp.current == 0 then
            if #Game.enemies == 1 then -- last enemy
                print("last dead")
                NextLevel.isVisible = true
            end
            print("Enemy deleted")
            table.remove(Game.enemies, n)
        end
        print("nb = " .. #Game.enemies)
    end
end

function Game.drawEnemies(isHealthDisplayed)
    for n = #Game.enemies, 1, -1 do
        Game.enemies[n]:draw(isHealthDisplayed)
    end
end

function Game.updateProjectiles(dt)
    for n = #Game.projectiles, 1, -1 do
        if Game.projectiles[n].update(Game.player, Game.enemies, dt) then
            table.remove(Game.projectiles, n)
        end
    end
end

function Game.drawProjectiles()
    for n = #Game.projectiles, 1, -1 do
        Game.projectiles[n].draw()
    end
end

function Game.update(dt)
    if not Game.roundOver then
        if Game.player:update(dt) then
            return "Game Over"
        end
    end

    if Game.roundStarting then
        if NextLevel.updateFading("start", dt) then
            Game.roundStarting = false
        else
            Game.player:move(dt * .5, 1)
        end
    else
        if not Game.roundOver then
            Game.player:handleInputs(dt)
            Game.updateEnemies(dt)
            Game.updateProjectiles(dt)
        end

        NextLevel.update(dt)
        if NextLevel.isVisible then
            if NextLevel.isInExit(Game.player.body.position.x, Game.player.body.position.y) then
                Game.roundOver = true
            end
        end
    end
    if Game.roundOver then
        if NextLevel.updateFading("end", dt) then
            Game.nextRound()
        end
    end

    return "Game"
end

function Game.nextRound()
    Game.currentLevel = Game.currentLevel + 1
    Game.init()
end

function Game.draw()
    NextLevel.drawExit()
    Game.player:draw(not Game.roundStarting)
    Game.drawEnemies(not Game.roundStarting)
    Game.drawProjectiles()
    NextLevel.drawArrow()

    if Game.roundStarting then
        NextLevel.drawFading("start")
    end

    if Game.roundOver then
        NextLevel.drawFading("end")
    end
end

function Game.loadLevel()
    if Game.currentLevel == 1 then
        table.insert(Game.enemies, Enemy:create(100, 100))
    elseif Game.currentLevel == 2 then
        table.insert(Game.enemies, Enemy:create(100, 100))
        table.insert(Game.enemies, Enemy:create(100, 200))
        table.insert(Game.enemies, Enemy:create(100, 300))
    end
end

function Game.handleKeyPressed(key)
    if key == "escape" then
        return "Pause"
    else
        return "Game"
    end
end

return Game
