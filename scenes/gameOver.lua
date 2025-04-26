local GameOver = {}
local buttonFactory = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function GameOver.new()
    GameOver.fonts = {
        giant = FontFactoryModule.getFont(2, "giant"),
        small = FontFactoryModule.getFont(1, "small")
    }
    GameOver.text = "Game Over"
    GameOver.size = {
        width = GameOver.fonts.giant:getWidth(GameOver.text),
        height = GameOver.fonts.giant:getHeight()
    }
    GameOver.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3
    }
    GameOver.buttonLabels = {"Restart", "Menu"}
end

function GameOver.init()
    GameOver.currentTime = 0
    GameOver.buttons = buttonFactory.createButtonList(GameOver.buttonLabels, GameOver.fonts.small, true)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function GameOver.update(dt)
    GameOver.currentTime = GameOver.currentTime + dt
    local isButtonHover = false
    for n = 1, #GameOver.buttons do
        local hasToStart = false
        if GameOver.currentTime > (n - 1) * GameOver.animation.deltaStartTimer then
            hasToStart = true
        end
        GameOver.buttons[n].update(hasToStart, GameOver.animation.buttonSpeed, dt)

        isButtonHover = isButtonHover or GameOver.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function GameOver.draw()
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(GameOver.text, GameOver.fonts.giant, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, GameOver.size.width, "left", 0, 1, 1, GameOver.size.width * .5, GameOver.size.height * .5)
    love.graphics.pop()
    for n = 1, #GameOver.buttons do
        GameOver.buttons[n].draw()
    end
end

function GameOver.checkMousePressed()
    for n = 1, #GameOver.buttons do
        GameOver.buttons[n].mousePressed()
    end
end

function GameOver.reset()
    for n = 1, #GameOver.buttons do
        GameOver.buttons[n].reset(true)
    end
    GameOver.currentTime = 0
end

function GameOver.checkMouseRelease()
    for n = 1, #GameOver.buttons do
        if GameOver.buttons[n].isClicked() then
            if GameOver.buttons[n].label.text == "Restart" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                return "Game"
            elseif GameOver.buttons[n].label.text == "Menu" then
                return "Menu"
            end
        end
    end
    return "Game Over"
end

return GameOver
