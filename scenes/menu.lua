local Menu = {}
local ButtonFactoryModule = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Menu.new()
    Menu.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3
    }
    Menu.buttonLabels = {"Play", "Options", "Credits", "Exit"}
    Menu.font = FontFactoryModule.getFont(1, "big")
end

function Menu.init()
    Menu.currentTime = 0
    Menu.buttons = ButtonFactoryModule.createButtonList(Menu.buttonLabels, Menu.font, false)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Menu.update(dt)
    Menu.currentTime = Menu.currentTime + dt
    local isButtonHover = false
    for n = 1, #Menu.buttons do
        local hasToStart = false
        if Menu.currentTime > (n - 1) * Menu.animation.deltaStartTimer then
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

function Menu.checkMouseRelease()
    for n = 1, #Menu.buttons do
        if Menu.buttons[n].isClicked() then
            if Menu.buttons[n].label.text == "Play" then
                return "Tutorial"
            elseif Menu.buttons[n].label.text == "Exit" then
                love.event.quit()
            end
        end
    end
    return "Menu"
end

return Menu
