local gameover = {}
local buttonFactory = require "factory/buttons"

function gameover.init()
    gameover.fonts = {
        giant = love.graphics.newFont("__fonts__/bubbles.ttf", 200),
        big = love.graphics.newFont("__fonts__/bubbles.ttf", 100),
        medium = love.graphics.newFont("__fonts__/bubbles.ttf", 50),
        small = love.graphics.newFont("__fonts__/bubbles.ttf", 25)
    }
    gameover.text = "Game Over"
    gameover.size = {
        width = gameover.fonts.giant:getWidth(gameover.text),
        height = gameover.fonts.giant:getHeight()
    }
    gameover.animation = {
        buttonSpeed = 900,
        deltaStartTimer = .3,
        currentTime = 0
    }
    gameover.buttonLabels = {"Restart", "Menu"}
    gameover.buttons = buttonFactory.createButtonList(gameover.buttonLabels, gameover.fonts.big, true)
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
    love.graphics.push("all")
    love.graphics.setColor({0, 0.32, 0.8, 0.6})
    love.graphics.printf(gameover.text, gameover.fonts.giant, love.graphics.getWidth() * .5, love.graphics.getHeight() * .3, gameover.size.width, "left", 0, 1, 1, gameover.size.width * .5, gameover.size.height * .5)
    love.graphics.pop()
    for n = 1, #gameover.buttons do
        gameover.buttons[n].draw()
    end
end

function gameover.checkMousePressed()
    for n = 1, #gameover.buttons do
        gameover.buttons[n].mousePressed()
    end
end

function gameover.reset()
    for n = 1, #gameover.buttons do
        gameover.buttons[n].reset(true)
    end
    gameover.animation.currentTime = 0
end

function gameover.checkMouseRelease()
    for n = 1, #gameover.buttons do
        if gameover.buttons[n].isClicked() then
            if gameover.buttons[n].label.text == "Restart" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                gameover.reset()
                scene = "game"
                player:reset()
                enemies = {}
                table.insert(enemies, Enemy:create(50, 50))
            elseif gameover.buttons[n].label.text == "Menu" then
                love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                gameover.reset()
                scene = "menu"
            end
        end
    end
end

return gameover
