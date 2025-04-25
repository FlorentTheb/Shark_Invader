local pause = {}
local buttonFactory = require "factory/buttons"

function pause.init()
    pause.fonts = {
        giant = love.graphics.newFont("__fonts__/bubbles.ttf", 200),
        big = love.graphics.newFont("__fonts__/bubbles.ttf", 100),
        medium = love.graphics.newFont("__fonts__/bubbles.ttf", 50),
        small = love.graphics.newFont("__fonts__/bubbles.ttf", 25)
    }
    pause.text = "Pause"
    pause.size = {
        width = pause.fonts.giant:getWidth(pause.text),
        height = pause.fonts.giant:getHeight()
    }
    pause.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    pause.buttonLabels = {"Resume", "Menu"}
    pause.buttons = buttonFactory.createButtonList(pause.buttonLabels, pause.fonts.big, true)
end

function pause.update(dt)
    pause.animation.currentTime = pause.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #pause.buttons do
        local hasToStart = false
        if pause.animation.currentTime > (n - 1) * pause.animation.deltaStartTimer then
            hasToStart = true
        end
        pause.buttons[n].update(hasToStart, pause.animation.buttonSpeed, dt)
        isButtonHover = isButtonHover or pause.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function pause.draw()
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(pause.text, pause.fonts.giant, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, pause.size.width, "left", 0, 1, 1, pause.size.width * .5, pause.size.height * .5)
    love.graphics.pop()
    for n = 1, #pause.buttons do
        pause.buttons[n].draw()
    end
end

function pause.checkMousePressed()
    for n = 1, #pause.buttons do
        pause.buttons[n].mousePressed()
    end
end

function pause.reset()
    for n = 1, #pause.buttons do
        pause.buttons[n].reset(true)
    end
    pause.animation.currentTime = 0
end

function pause.checkMouseRelease()
    for n = 1, #pause.buttons do
        if pause.buttons[n].isClicked() then
            if pause.buttons[n].label.text == "Resume" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                pause.reset()
                return "game"
            elseif pause.buttons[n].label.text == "Menu" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                pause.reset()
                return "menu"
            end
        end
    end
    return "pause"
end

return pause
