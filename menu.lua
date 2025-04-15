local menu = {}

local buttons = {}

function menu.init()
    menu.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    menu.fontSizeRatio = 0.75
    menu.playButton = {
        text = "Play",
        speedTransi = 1500,
        speedFading = 2,
        isInteractable = false,
        fadeRatio = 1,
        color = {0, .54, 0.9, 1},
        currentPos = {
            x = -menu.font:getWidth("Play"),
            y = love.graphics.getHeight() * .3
        },
        finalPos = {
            x = love.graphics.getWidth() * .5 - menu.font:getWidth("Play") * .5,
            y = love.graphics.getHeight() * .3
        }
    }
end

function menu.update(dt)
    if menu.playButton.currentPos.x < menu.playButton.finalPos.x then
        menu.playButton.currentPos.x = menu.playButton.currentPos.x + menu.playButton.speedTransi * dt
        if menu.playButton.speedTransi > 100 then
            menu.playButton.speedTransi = menu.playButton.speedTransi - 1.55 * menu.playButton.speedTransi * dt
        end
    elseif menu.playButton.currentPos.x > menu.playButton.finalPos.x then
        menu.playButton.currentPos.x = menu.playButton.finalPos.x
        menu.playButton.isInteractable = true
    else
        menu.playButton.isInteractable = true
    end

    if menu.isHover() then
        menu.playButton.color = {0, .36, .6, 1}
        if scene == "menu" then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        end
    else
        menu.playButton.color = {0, .54, 0.9, 1}
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
end

function menu.draw()
    --love.graphics.line(love.graphics.getWidth() * .5, 0, love.graphics.getWidth() * .5, love.graphics.getHeight())
    love.graphics.push("all")
    local button = menu.playButton
    local currentColor = button.color
    love.graphics.setColor({0, 0, 0, 0.3})
    --love.graphics.circle("fill", menu.playButton.currentPos.x, menu.playButton.currentPos.y, 5)
    love.graphics.rectangle("fill", menu.playButton.currentPos.x - 15, menu.playButton.currentPos.y - 5, menu.font:getWidth(menu.playButton.text) + 43, menu.font:getHeight() + 3, 20, 20)
    love.graphics.setColor(currentColor)
    love.graphics.rectangle("fill", menu.playButton.currentPos.x - 20, menu.playButton.currentPos.y - 10, menu.font:getWidth(menu.playButton.text) + 40, menu.font:getHeight(), 20, 20)
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", menu.playButton.currentPos.x - 20, menu.playButton.currentPos.y - 10, menu.font:getWidth(menu.playButton.text) + 40, menu.font:getHeight(), 20, 20)
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.printf(button.text, menu.font, menu.playButton.currentPos.x, menu.playButton.currentPos.y, 700)
    love.graphics.pop()
end

function menu.isHover()
    local mX, mY = love.mouse.getPosition()
    if menu.playButton.currentPos.x == menu.playButton.finalPos.x then
        if mX < menu.playButton.currentPos.x + menu.font:getWidth(menu.playButton.text) and mX > menu.playButton.currentPos.x then
            if mY < menu.playButton.currentPos.y + menu.font:getHeight() * menu.fontSizeRatio and mY > menu.playButton.currentPos.y then
                if love.mouse.isDown(1) then
                    scene = "game"
                    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                end
                return true
            end
        end
    end
    return false
end

return menu
