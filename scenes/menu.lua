local Menu = {}
local buttonFactory = require "factory/buttons"

function Menu.init()
    Menu.fonts = {
        big = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 100),
        medium = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 50)
    }
    Menu.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    Menu.buttonLabels = {"Play", "Options", "Credits", "Exit"}
    Menu.buttons = buttonFactory.createButtonList(Menu.buttonLabels, Menu.fonts.big, false)
end

function Menu.update(dt)
    Menu.animation.currentTime = Menu.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #Menu.buttons do
        local hasToStart = false
        if Menu.animation.currentTime > (n - 1) * Menu.animation.deltaStartTimer then
            hasToStart = true
        end
        Menu.buttons[n].update(hasToStart, Menu.animation.buttonSpeed, dt)

        isButtonHover = isButtonHover or Menu.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function Menu.draw()
    for n = 1, #Menu.buttons do
        Menu.buttons[n].draw()
    end
end

function Menu.checkMousePressed()
    for n = 1, #Menu.buttons do
        Menu.buttons[n].mousePressed()
    end
end

function Menu.reset()
    for n = 1, #Menu.buttons do
        Menu.buttons[n].reset(false)
    end
    Menu.animation.currentTime = 0
end

function Menu.checkMouseRelease()
    for n = 1, #Menu.buttons do
        if Menu.buttons[n].isClicked() then
            if Menu.buttons[n].label.text == "Play" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                Menu.reset()
                return "tutorial"
            elseif Menu.buttons[n].label.text == "Exit" then
                love.event.quit()
            end
        end
    end
    return "menu"
end

return Menu
