local menu = {}
local buttonFactory = require "factory/buttons"

function menu.init()
    menu.fonts = {
        big = love.graphics.newFont("__fonts__/bubbles.ttf", 100),
        medium = love.graphics.newFont("__fonts__/bubbles.ttf", 50),
        small = love.graphics.newFont("__fonts__/bubbles.ttf", 25)
    }
    menu.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    menu.buttonLabels = {"Play", "Options", "Credits", "Exit"}
    menu.buttons = buttonFactory.createButtonList(menu.buttonLabels, menu.fonts.big, false)
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

function menu.reset()
    for n = 1, #menu.buttons do
        menu.buttons[n].reset(false)
    end
    menu.animation.currentTime = 0
end

function menu.checkMouseRelease()
    for n = 1, #menu.buttons do
        if menu.buttons[n].isClicked() then
            if menu.buttons[n].label.text == "Play" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                menu.reset()
                return "game"
            elseif menu.buttons[n].label.text == "Exit" then
                love.event.quit()
            end
        end
    end
    return "menu"
end

return menu
