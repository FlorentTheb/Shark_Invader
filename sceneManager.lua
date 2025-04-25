local Menu = require "scenes/menu"
local GameOver = require "scenes/gameOver"
local Pause = require "scenes/pause"
local Tutorial = require "scenes/tutorial"
local Game = require "scenes/game"

SceneManager = {}

function SceneManager:init()
    self.currentScene = "menu"
    Menu.init()
    GameOver.init()
    Pause.init()
    Tutorial.init()
    Game.init()
end

function SceneManager:update(dt)
    if self.currentScene == "menu" then
        Menu.update(dt)
    elseif self.currentScene == "game" then
        if Game.update(dt) == "over" then
            self.currentScene = "gameover"
            Game.reset()
        end
    elseif self.currentScene == "gameover" then
        GameOver.update(dt)
    elseif self.currentScene == "pause" then
        Pause.update(dt)
    elseif self.currentScene == "tuorial" then
        Tutorial.update(dt)
    end
end

function SceneManager:draw(dt)
    if self.currentScene == "menu" then
        Menu.draw(dt)
    elseif self.currentScene == "game" then
        Game.draw(dt)
    elseif self.currentScene == "gameover" then
        GameOver.draw(dt)
    elseif self.currentScene == "pause" then
        Pause.draw(dt)
    elseif self.currentScene == "tuorial" then
        Tutorial.draw(dt)
    end
end

function SceneManager:handleMousePressed(_, _, button)
    if self.currentScene == "menu" and button == 1 then
        Menu.checkMousePressed()
    elseif self.currentScene == "gameover" and button == 1 then
        GameOver.checkMousePressed()
    elseif self.currentScene == "pause" and button == 1 then
        Pause.checkMousePressed()
    end
end

function SceneManager:handleMouseReleased(_, _, button)
    if self.currentScene == "menu" and button == 1 then
        self.currentScene = Menu.checkMouseRelease()
        if self.currentScene == "game" then
            Game.loadLevel()
        end
    elseif self.currentScene == "gameover" and button == 1 then
        self.currentScene = GameOver.checkMouseRelease()
        if self.currentScene == "game" then
            Game.loadLevel()
        end
    elseif self.currentScene == "pause" and button == 1 then
        self.currentScene = Pause.checkMouseRelease()
        if self.currentScene == "menu" then
            Game.reset()
        end
    end
end

function SceneManager:handleKeyPressed(key)
    if self.currentScene == "game" and key == "escape" then
        self.currentScene = "pause"
    end
end
