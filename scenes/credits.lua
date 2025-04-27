local Credits = {}
local buttonFactory = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Credits.new()
    Credits.fonts = {
        giant = FontFactoryModule.getFont(2, "giant"),
        medium = FontFactoryModule.getFont(1, "medium")
    }
    Credits.title = "Credits"
    Credits.texts = {
        "Game by Flowfi",
        "Mes autres jeux : https://flowfi.itch.io"
    }
    Credits.size = {
        width = Credits.fonts.giant:getWidth(Credits.title),
        height = Credits.fonts.giant:getHeight()
    }
    Credits.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3
    }
end

function Credits.init()
    Credits.currentTime = 0
    Credits.buttons = buttonFactory.createButtonList({"Retour"}, Credits.fonts.medium)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Credits.update(dt)
    Credits.currentTime = Credits.currentTime + dt
    local isButtonHover = false
    for n = 1, #Credits.buttons do
        if Credits.currentTime > (n - 1) * Credits.animation.deltaStartTimer and Credits.buttons[n].state.isAtStart then
            Credits.buttons[n].state.isMoving = true
        end
        Credits.buttons[n].update(nil, love.graphics.getHeight() * .85, n, #Credits.buttons, false, dt)

        isButtonHover = isButtonHover or Credits.buttons[n].state.isHover
        if isButtonHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
end

function Credits.draw()
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(Credits.title, Credits.fonts.giant, love.graphics.getWidth() * .5, Credits.fonts.giant:getHeight(), Credits.size.width, "left", 0, 1, 1, Credits.size.width * .5, Credits.size.height * .5)
    love.graphics.setColor(1, 1, 1, 1)
    for n = 1, #Credits.texts do
        local text = Credits.texts[n]
        local delta = (n % 2 == 0) and 1 or -1
        love.graphics.printf(text, Credits.fonts.medium, love.graphics.getWidth() * .5, love.graphics.getHeight() * .5 + delta * Credits.fonts.medium:getHeight(), Credits.fonts.medium:getWidth(text), "left", 0, 1, 1, Credits.size.width * .5, 0)
    end
    love.graphics.pop()
    for n = 1, #Credits.buttons do
        Credits.buttons[n].draw()
    end
end

function Credits.checkMousePressed()
    for n = 1, #Credits.buttons do
        Credits.buttons[n].mousePressed()
    end
end

function Credits.checkMouseRelease()
    for n = 1, #Credits.buttons do
        if Credits.buttons[n].isClicked() then
            if Credits.buttons[n].label.text == "Retour" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                return "Menu"
            end
        end
    end
    return "Credits"
end

return Credits
