local pause = {}
local buttonFactory = require "factory/buttons"

function pause.init()
    pause.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    pause.text = "Pause"
    pause.size = {
        width = pause.font:getWidth(pause.text),
        height = pause.font:getHeight()
    }
    pause.animation = {
        buttonSpeed = 600,
        deltaStartTimer = .5,
        currentTime = 0
    }
    pause.buttonLabels = {"Resume", "Menu"}
    pause.buttons = buttonFactory.createButtonList(pause.buttonLabels, pause.font, true)
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
    love.graphics.printf(pause.text, pause.font, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, pause.size.width, "left", 0, 2, 2, pause.size.width * .5, pause.size.height * .5)
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
                scene = "game"
            elseif pause.buttons[n].label.text == "Menu" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                pause.reset()
                scene = "menu"
            end
        end
    end
end

return pause
