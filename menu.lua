local menu = {}
local buttonFactory = require "utils/factoryButton"

function menu.init()
    menu.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    menu.animation = {
        buttonSpeed = 600,
        deltaStartTimer = .5,
        currentTime = 0
    }
    menu.buttonLabels = {"Play", "Options", "Credits", "Exit"}
    menu.buttons = buttonFactory.createButtonList(menu.buttonLabels, menu.font, false)
end

function menu.update(dt)
    menu.animation.currentTime = menu.animation.currentTime + dt
    local isButtonHover = false
    for n = 1, #menu.buttons do
        local hasToStart = false
        if menu.animation.currentTime > (n - 1) * menu.animation.deltaStartTimer then
            hasToStart = true
        end
        menu.buttons[n].update(hasToStart, menu.animation.buttonSpeed, dt)
        isButtonHover = isButtonHover or menu.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function menu.draw()
    for n = 1, #menu.buttons do
        menu.buttons[n].draw()
    end
end

function menu.checkMousePressed()
    for n = 1, #menu.buttons do
        menu.buttons[n].mousePressed()
    end
end

function menu.checkMouseRelease()
    for n = 1, #menu.buttons do
        if menu.buttons[n].isClicked() then
            if menu.buttons[n].label.text == "Play" then
                scene = "game"
            end
        end
    end
end

return menu
