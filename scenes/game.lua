local Entity = require "objects/entity"
local Player = Entity.Player
local Enemy = Entity.Enemy
local Projectile = require "objects/projectile"
local NextLevel = require "utils/nextLevel"
local FontFactoryModule = require "factory/fonts"

local Game = {}

function Game.new()
    Projectile.new()
    Game.player = Player:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .5)
    Game.enemies = {}
    Game.maxLevel = 1
    Game.currentLevel = 1
    Game.levelDisplayFont = FontFactoryModule.getFont(2, "big")
end

function Game.init()
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    NextLevel.init()
    Projectile.init()
    Game.levelDisplayAlpha = 0
    Game.levelDisplayVector = 1
    Game.levelDisplayOff = false
    Game.projectiles = Projectile.projectilesTable
    Game.player.body.position.x = love.graphics.getWidth()
    Game.player.body.position.y = love.graphics.getHeight() * .5
    Game.player.body.angle = math.pi
    Game.roundStarting = true
    Game.roundOver = false
    Game.currentTime = 0
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
                NextLevel.isVisible = true
                if Game.currentLevel == Game.maxLevel then
                    Game.roundOver = true
                end
            end
            table.remove(Game.enemies, n)
        end
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

function Game.updateLevelFading(dt)
    if Game.levelDisplayAlpha >= 1 then
        Game.levelDisplayVector = -Game.levelDisplayVector
    end

    if Game.levelDisplayAlpha ~= 0 or Game.levelDisplayVector > 0 then
        Game.levelDisplayAlpha = Game.levelDisplayAlpha + dt * Game.levelDisplayVector * .5
    end
end

function Game.update(dt)
    Game.currentTime = Game.currentTime + dt
    if not Game.roundOver then
        if Game.player:update(dt) then
            return "Game Over"
        end
    end

    if Game.roundStarting then
        if NextLevel.updateFading("start", dt) then
            Game.roundStarting = false
        else
            Game.player.body.position.x = love.graphics.getWidth() - Game.currentTime * Game.player.speedMove * .5
            Game.player.body.position.y = love.graphics.getHeight() * .5
            Game.player.body.angle = math.pi
        end
    else
        Game.updateLevelFading(dt)
        Game.updateEnemies(dt)
        if not Game.roundOver then
            Game.player:handleInputs(dt)
            Game.updateProjectiles(dt)
        end

        NextLevel.update(dt)
        if NextLevel.isVisible and not Game.roundOver then
            if NextLevel.isInExit(Game.player.body.position.x, Game.player.body.position.y) then
                Game.roundOver = true
            end
        end
    end
    if Game.roundOver then
        if NextLevel.updateFading("end", dt) then
            return Game.nextRound()
        end
    end

    return "Game"
end

function Game.nextRound()
    if Game.currentLevel < Game.maxLevel then
        Game.currentLevel = Game.currentLevel + 1
        Game.init()
        return "Game"
    else
        return "Game Over"
    end
end

function Game.draw()
    if not Game.roundOver then
        NextLevel.drawExit()
    end
    if not Game.roundStarting then
        local levelDisplay = "Niveau " .. Game.currentLevel .. " / " .. Game.maxLevel
        love.graphics.push("all")
        love.graphics.setColor(1, 1, 1, Game.levelDisplayAlpha)
        love.graphics.printf(levelDisplay, Game.levelDisplayFont, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, Game.levelDisplayFont:getWidth(levelDisplay), "left", 0, 1, 1, Game.levelDisplayFont:getWidth(levelDisplay) * .5, Game.levelDisplayFont:getHeight() * .5)
        love.graphics.pop()
    end
    Game.player:draw(not Game.roundStarting)
    Game.drawEnemies(not Game.roundStarting)
    Game.drawProjectiles()
    if not Game.roundOver then
        NextLevel.drawArrow()
    end

    if Game.roundStarting then
        NextLevel.drawFading("start")
    end

    if Game.roundOver then
        NextLevel.drawFading("end")
    end
end

function Game.loadLevel()
    if Game.currentLevel == 1 then
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .5))
    elseif Game.currentLevel == 2 then
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .7))
    elseif Game.currentLevel == 3 then
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .7))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .7, love.graphics.getHeight() * .5))
    elseif Game.currentLevel == 4 then
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .7))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .7, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .1, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .1, love.graphics.getHeight() * .7))
    elseif Game.currentLevel == 5 then
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .5, love.graphics.getHeight() * .7))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .7, love.graphics.getHeight() * .5))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .1, love.graphics.getHeight() * .3))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .1, love.graphics.getHeight() * .7))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .1))
        table.insert(Game.enemies, Enemy:create(love.graphics.getWidth() * .3, love.graphics.getHeight() * .9))
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
