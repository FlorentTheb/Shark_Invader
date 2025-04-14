local menu = {}

function menu.init()
    menu.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    menu.playButton = {
        text = "Play",
        speedTransi = 400,
        speedFading = 2,
        isInteractable = false,
        fadeRatio = 1,
        color = {1, 1, 1, 1},
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
    elseif menu.playButton.currentPos.x > menu.playButton.finalPos.x then
        menu.playButton.currentPos.x = menu.playButton.finalPos.x
        menu.playButton.isInteractable = true
    else
        menu.playButton.isInteractable = true
    end

    if menu.isHover() then
        if menu.playButton.fadeRatio > 0 then
            menu.playButton.fadeRatio = menu.playButton.fadeRatio - dt * menu.playButton.speedFading
        elseif menu.playButton.fadeRatio < 0 then
            menu.playButton.fadeRatio = 0
        end
        if scene == "menu" then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        end
    else
        if menu.playButton.fadeRatio < 1 then
            menu.playButton.fadeRatio = menu.playButton.fadeRatio + dt * menu.playButton.speedFading * 2
        elseif menu.playButton.fadeRatio > 1 then
            menu.playButton.fadeRatio = 1
        end
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
    menu.playButton.color = {menu.playButton.fadeRatio, menu.playButton.fadeRatio, 1, 1}
end

function menu.draw()
    --love.graphics.line(love.graphics.getWidth() * .5, 0, love.graphics.getWidth() * .5, love.graphics.getHeight())
    love.graphics.push("all")
    local button = menu.playButton
    local currentColor = button.color
    love.graphics.setColor(currentColor)
    love.graphics.printf(button.text, menu.font, menu.playButton.currentPos.x, menu.playButton.currentPos.y, 700)
    love.graphics.pop()
    --love.graphics.circle("fill", menu.playButton.currentPos.x, menu.playButton.currentPos.y, 5)
    --love.graphics.rectangle("line", menu.playButton.currentPos.x, menu.playButton.currentPos.y, menu.font:getWidth(menu.playButton.text), menu.font:getHeight())
end

function menu.isHover()
    local mX, mY = love.mouse.getPosition()
    if menu.playButton.currentPos.x == menu.playButton.finalPos.x then
        if mX < menu.playButton.currentPos.x + menu.font:getWidth(menu.playButton.text) and mX > menu.playButton.currentPos.x then
            if mY < menu.playButton.currentPos.y + menu.font:getHeight() and mY > menu.playButton.currentPos.y then
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
