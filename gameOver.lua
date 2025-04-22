local gameover = {}
local buttonFactory = require "utils/factoryButton"

function gameover.init()
    gameover.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    gameover.animation = {
        buttonSpeed = 600,
        deltaStartTimer = .5,
        currentTime = 0
    }
    gameover.buttonLabels = {"Restart", "Menu"}
    gameover.buttons = buttonFactory.createButtonList(gameover.buttonLabels, gameover.font, true)
end

function gameover.update(dt)
    gameover.animation.currentTime = gameover.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #gameover.buttons do
        local hasToStart = false
        if gameover.animation.currentTime > (n - 1) * gameover.animation.deltaStartTimer then
            hasToStart = true
        end
        gameover.buttons[n].update(hasToStart, gameover.animation.buttonSpeed, dt)
        isButtonHover = isButtonHover or gameover.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function gameover.draw()
    for n = 1, #gameover.buttons do
        gameover.buttons[n].draw()
    end
end

function gameover.checkMousePressed()
    for n = 1, #gameover.buttons do
        gameover.buttons[n].mousePressed()
    end
end

function gameover.checkMouseRelease()
    for n = 1, #gameover.buttons do
        if gameover.buttons[n].isClicked() then
            if gameover.buttons[n].label.text == "Play" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                scene = "game"
            end
        end
    end
end

return gameover
