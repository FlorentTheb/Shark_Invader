local Pause = {}
local buttonFactory = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Pause.new()
    Pause.fonts = {
        giant = FontFactoryModule.getFont(2, "giant"),
        medium = FontFactoryModule.getFont(1, "medium")
    }
    Pause.text = "Pause"
    Pause.size = {
        width = Pause.fonts.giant:getWidth(Pause.text),
        height = Pause.fonts.giant:getHeight()
    }
    Pause.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3
    }
    Pause.buttonLabels = {"Resume", "Options", "Menu"}
end

function Pause.init()
    Pause.currentTime = 0
    Pause.buttons = buttonFactory.createButtonList(Pause.buttonLabels, Pause.fonts.medium, true)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Pause.update(dt)
    Pause.currentTime = Pause.currentTime + dt
    local isButtonHover = false
    for n = 1, #Pause.buttons do
        local hasToStart = false
        if Pause.currentTime > (n - 1) * Pause.animation.deltaStartTimer then
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

function Pause.checkMouseRelease()
    for n = 1, #Pause.buttons do
        if Pause.buttons[n].isClicked() then
            if Pause.buttons[n].label.text == "Resume" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                return "Game"
            elseif Pause.buttons[n].label.text == "Menu" then
                return "Menu"
            end
        end
    end
    return "Pause"
end

return Pause
