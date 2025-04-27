local Menu = require "scenes/menu"
local GameOver = require "scenes/gameOver"
local Pause = require "scenes/pause"
local Tutorial = require "scenes/tutorial"
local Game = require "scenes/game"
local Settings = require "scenes/settings"
local NextLevel = require "utils/nextLevel"

local SceneManager = {}

function SceneManager:new()
    Menu.new()
    Game.new()
    Tutorial.new(Game.player)
    NextLevel.new()
    GameOver.new()
    Pause.new()
    Settings.new()
    SceneManager.init()
end

function SceneManager.init()
    SceneManager.currentScene = "Menu"
    Settings.init()
    Menu.init()
end

function SceneManager.update(dt)
    local previousScene = SceneManager.currentScene
    if SceneManager.currentScene == "Menu" then
        Menu.update(Settings.isVisible, dt)
    elseif SceneManager.currentScene == "Game" then
        SceneManager.currentScene = Game.update(dt)
    elseif SceneManager.currentScene == "Game Over" then
        GameOver.update(Settings.isVisible, dt)
    elseif SceneManager.currentScene == "Pause" then
        Pause.update(Settings.isVisible, dt)
    elseif SceneManager.currentScene == "Tutorial" then
        SceneManager.currentScene = Tutorial.update(dt)
    end
    if Settings.isVisible then
        Settings.update(dt)
    end

    if previousScene ~= SceneManager.currentScene then
        SceneManager.updateNewScene(previousScene)
        if SceneManager.currentScene == "Game Over" then
            GameOver.update(Settings.isVisible, dt)
        end
    end
end

function SceneManager.draw(dt)
    if SceneManager.currentScene == "Menu" then
        Menu.draw(dt)
    elseif SceneManager.currentScene == "Game" then
        Game.draw(dt)
    elseif SceneManager.currentScene == "Game Over" then
        GameOver.draw(dt)
    elseif SceneManager.currentScene == "Pause" then
        Pause.draw(dt)
    elseif SceneManager.currentScene == "Tutorial" then
        Tutorial.draw()
    end

    if Settings.isVisible then
        Settings.draw()
    end
end

function SceneManager.handleMousePressed(_, _, button)
    if SceneManager.currentScene == "Menu" and button == 1 then
        Menu.checkMousePressed()
    elseif SceneManager.currentScene == "Game Over" and button == 1 then
        GameOver.checkMousePressed()
    elseif SceneManager.currentScene == "Pause" and button == 1 then
        Pause.checkMousePressed()
    elseif SceneManager.currentScene == "Tutorial" and button == 1 then
        Tutorial.checkMousePressed()
    end

    if Settings.isVisible then
        Settings.checkMousePressed()
    end
end

function SceneManager.handleMouseReleased(_, _, button)
    local previousScene = SceneManager.currentScene
    if SceneManager.currentScene == "Menu" and button == 1 and not Settings.isVisible then
        SceneManager.currentScene = Menu.checkMouseRelease()
    elseif SceneManager.currentScene == "Game Over" and button == 1 then
        SceneManager.currentScene = GameOver.checkMouseRelease()
    elseif SceneManager.currentScene == "Pause" and button == 1 then
        SceneManager.currentScene = Pause.checkMouseRelease()
    elseif SceneManager.currentScene == "Tutorial" and button == 1 then
        SceneManager.currentScene = Tutorial.checkMouseRelease()
    end

    if SceneManager.currentScene == "Settings" then
        Settings.isVisible = true
        SceneManager.currentScene = previousScene
    end

    if Settings.isVisible then
        Settings.checkMouseRelease()
    end

    if previousScene ~= SceneManager.currentScene then
        SceneManager.updateNewScene(previousScene)
    end
end

function SceneManager.updateNewScene(previousScene)
    print(previousScene .. " => " .. SceneManager.currentScene)
    if SceneManager.currentScene == "Play" and Settings.conf[2].toggle.isToggled then
        SceneManager.currentScene = "Game"
    elseif SceneManager.currentScene == "Play" then
        SceneManager.currentScene = "Tutorial"
    end
    
    if SceneManager.currentScene == "Menu" then
        Menu.init()
        if previousScene == "Pause" then
            Game.reset()
        end
    elseif SceneManager.currentScene == "Game Over" then
        if Game.player.hp.current > 0 then
            GameOver.text = "You win !"
        else
            GameOver.text = "You lose !"
        end
        Game.reset()
        GameOver.init()
    elseif SceneManager.currentScene == "Pause" then
        Pause.init()
    elseif SceneManager.currentScene == "Tutorial" then
        Tutorial.init()
    elseif SceneManager.currentScene == "Game" then
        if previousScene ~= "Pause" then
            Game.init()
        end
    end
end

function SceneManager.handleKeyPressed(key)
    local previousScene = SceneManager.currentScene
    if SceneManager.currentScene == "Game" then
        SceneManager.currentScene = Game.handleKeyPressed(key)
    end

    if previousScene ~= SceneManager.currentScene then
        SceneManager.updateNewScene(previousScene)
    end
end

return SceneManager
