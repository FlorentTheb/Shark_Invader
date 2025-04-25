local Gameover = {}
local buttonFactory = require "factory/buttons"

function Gameover.init()
    Gameover.fonts = {
        giant = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 200),
        big = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 100)
    }
    Gameover.text = "Game Over"
    Gameover.size = {
        width = Gameover.fonts.giant:getWidth(Gameover.text),
        height = Gameover.fonts.giant:getHeight()
    }
    Gameover.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    Gameover.buttonLabels = {"Restart", "Menu"}
    Gameover.buttons = buttonFactory.createButtonList(Gameover.buttonLabels, Gameover.fonts.big, true)
end

function Gameover.update(dt)
    Gameover.animation.currentTime = Gameover.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #Gameover.buttons do
        local hasToStart = false
        if Gameover.animation.currentTime > (n - 1) * Gameover.animation.deltaStartTimer then
            hasToStart = true
        end
        Gameover.buttons[n].update(hasToStart, Gameover.animation.buttonSpeed, dt)
        isButtonHover = isButtonHover or Gameover.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function Gameover.draw()
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(Gameover.text, Gameover.fonts.giant, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, Gameover.size.width, "left", 0, 1, 1, Gameover.size.width * .5, Gameover.size.height * .5)
    love.graphics.pop()
    for n = 1, #Gameover.buttons do
        Gameover.buttons[n].draw()
    end
end

function Gameover.checkMousePressed()
    for n = 1, #Gameover.buttons do
        Gameover.buttons[n].mousePressed()
    end
end

function Gameover.reset()
    for n = 1, #Gameover.buttons do
        Gameover.buttons[n].reset(true)
    end
    Gameover.animation.currentTime = 0
end

function Gameover.checkMouseRelease()
    for n = 1, #Gameover.buttons do
        if Gameover.buttons[n].isClicked() then
            if Gameover.buttons[n].label.text == "Restart" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                Gameover.reset()
                return "game"
            elseif Gameover.buttons[n].label.text == "Menu" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                Gameover.reset()
                return "menu"
            end
        end
    end
    return "gameover"
end

return Gameover
