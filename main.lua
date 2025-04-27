local SceneManager = require "utils/sceneManager"
local FontFactoryModule = require "factory/fonts"
require "utils/soundManager"

function love.load()
    math.randomseed(os.time())
    SoundManager.new()
    love.graphics.setBackgroundColor({0.6, 0.8, 1})
    FontFactoryModule.init()
    SceneManager.new()
end

function love.update(dt)
    SoundManager.update()
    SoundManager.music:play()
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()
end

function love.mousepressed(x, y, button)
    SceneManager.handleMousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
    SceneManager.handleMouseReleased(x, y, button)
end

function love.keypressed(key)
    SceneManager.handleKeyPressed(key)
end
