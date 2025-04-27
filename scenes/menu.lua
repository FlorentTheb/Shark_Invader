local Menu = {}
local ButtonFactoryModule = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Menu.new()
    Menu.animation = {
        buttonSpeed = 1200,
        deltaStartTimer = .3
    }
    Menu.buttonLabels = {"Jouer", "Options", "Credits", "Quitter"}
    Menu.font = FontFactoryModule.getFont(1, "big")
end

function Menu.init()
    Menu.currentTime = 0
    Menu.buttons = ButtonFactoryModule.createButtonList(Menu.buttonLabels, Menu.font)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Menu.update(isSettingsPanelOpen, dt)
    Menu.currentTime = Menu.currentTime + dt
    local isButtonHover = false
    for n = 1, #Menu.buttons do
        if Menu.currentTime > (n - 1) * Menu.animation.deltaStartTimer and Menu.buttons[n].state.isAtStart then
            Menu.buttons[n].state.isMoving = true
        end

        Menu.buttons[n].update(love.graphics.getWidth() * .5, nil, n, #Menu.buttons, isSettingsPanelOpen, dt)

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
            if Menu.buttons[n].label.text == "Jouer" then
                return "Play"
            elseif Menu.buttons[n].label.text == "Options" then
                return "Settings"
            elseif Menu.buttons[n].label.text == "Credits" then
                return "Credits"
            elseif Menu.buttons[n].label.text == "Quitter" then
                love.event.quit()
            end
        end
    end
    return "Menu"
end

return Menu
