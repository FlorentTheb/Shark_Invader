local Pause = {}
local buttonFactory = require "factory/buttons"

function Pause.init()
    Pause.fonts = {
        giant = love.graphics.newFont("assets/__fonts__/gloomie_saturday.otf", 200),
        small = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 50)
    }
    Pause.text = "Pause"
    Pause.size = {
        width = Pause.fonts.giant:getWidth(Pause.text),
        height = Pause.fonts.giant:getHeight()
    }
    Pause.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    Pause.buttonLabels = {"Resume", "Options", "Menu"}
    Pause.buttons = buttonFactory.createButtonList(Pause.buttonLabels, Pause.fonts.small, true)
end

function Pause.update(dt)
    Pause.animation.currentTime = Pause.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #Pause.buttons do
        local hasToStart = false
        if Pause.animation.currentTime > (n - 1) * Pause.animation.deltaStartTimer then
            hasToStart = true
        end
        Pause.buttons[n].update(hasToStart, Pause.animation.buttonSpeed, dt)

        isButtonHover = isButtonHover or Pause.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function Pause.draw()
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(Pause.text, Pause.fonts.giant, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, Pause.size.width, "left", 0, 1, 1, Pause.size.width * .5, Pause.size.height * .5)
    love.graphics.pop()
    for n = 1, #Pause.buttons do
        Pause.buttons[n].draw()
    end
end

function Pause.checkMousePressed()
    for n = 1, #Pause.buttons do
        Pause.buttons[n].mousePressed()
    end
end

function Pause.reset()
    for n = 1, #Pause.buttons do
        Pause.buttons[n].reset(true)
    end
    Pause.animation.currentTime = 0
end

function Pause.checkMouseRelease()
    for n = 1, #Pause.buttons do
        if Pause.buttons[n].isClicked() then
            if Pause.buttons[n].label.text == "Resume" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                Pause.reset()
                return "game"
            elseif Pause.buttons[n].label.text == "Menu" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                Pause.reset()
                return "menu"
            end
        end
    end
    return "pause"
end

return Pause
