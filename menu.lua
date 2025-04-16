local menu = {}

function menu.init()
    menu.font = love.graphics.newFont("__fonts__/bubbles.ttf", 100)
    menu.fontUpperSpace = menu.font:getHeight() * 0.125

    menu.buttonTexts = {}
    menu.createButtonText("Play")
    menu.createButtonText("Options")
    menu.createButtonText("Credits")
    menu.createButtonText("Exit")
    menu.buttonPadding = 20
    menu.buttonWidth = 0
    menu.buttonHeight = menu.font:getHeight() + 2 * menu.buttonPadding
    menu.buttonShadowOffset = 5

    for n = 1, #menu.buttonTexts do
        menu.buttonWidth = math.max(menu.buttonWidth, math.floor(menu.buttonTexts[n].font:getWidth(menu.buttonTexts[n].text)) + 2 * menu.buttonPadding)
        menu.buttonTexts[n].finalePos.x = love.graphics.getWidth() * .5
        menu.buttonTexts[n].finalePos.y = math.floor(love.graphics.getHeight() / (#menu.buttonTexts + 1)) * n
    end

    for n = 1, #menu.buttonTexts do
        menu.buttonTexts[n].currentPos.x = -menu.buttonWidth
        menu.buttonTexts[n].currentPos.y = menu.buttonTexts[n].finalePos.y
    end
    menu.animation = {
        buttonSpeed = 500,
        deltaStartTimer = 2,
        currentTime = 0
    }
end

function menu.createButtonText(buttonText)
    local b = {}
    b.font = menu.font
    b.text = buttonText
    b.currentPos = {x, y}
    b.finalePos = {x, y}
    b.origin = {
        x = b.font:getWidth(b.text) * .5,
        y = menu.fontUpperSpace + (b.font:getAscent() - menu.fontUpperSpace) * .5
    }
    b.isHover = false
    b.isClicked = false

    table.insert(menu.buttonTexts, b)
end

function menu.update(dt)
    updateButtonsPosition(dt)
    checkButtonHover()
end

function menu.draw()
    for n = 1, #menu.buttonTexts do
        love.graphics.push("all")
        local b = menu.buttonTexts[n]
        love.graphics.setColor({0, 0, 0, 0.3})
        local buttonTopLeftX = b.currentPos.x - menu.buttonWidth * .5
        local buttonTopLeftY = b.currentPos.y - menu.buttonHeight * .5
        local buttonRoundCornerRatio = 10
        love.graphics.rectangle("fill", buttonTopLeftX + menu.buttonShadowOffset, buttonTopLeftY + menu.buttonShadowOffset, menu.buttonWidth, menu.buttonHeight, buttonRoundCornerRatio, buttonRoundCornerRatio)
        if b.isHover then
            love.graphics.setColor({0, .7, .7})
        else
            love.graphics.setColor({0, .5, .5})
        end
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("fill", buttonTopLeftX, buttonTopLeftY, menu.buttonWidth, menu.buttonHeight, buttonRoundCornerRatio, buttonRoundCornerRatio)

        love.graphics.setColor({1, 1, 1})
        love.graphics.printf(b.text, b.font, b.currentPos.x, b.currentPos.y, menu.buttonWidth, "left", 0, 1, 1, b.origin.x, b.origin.y)
        love.graphics.pop()
    end
end

function updateButtonsPosition(dt)
    for n = 1, #menu.buttonTexts do
        local b = menu.buttonTexts[n]
        menu.animation.currentTime = menu.animation.currentTime + dt
        if b.currentPos.x < b.finalePos.x and menu.animation.currentTime > menu.animation.deltaStartTimer * (n - 1) then
            b.currentPos.x = b.currentPos.x + menu.animation.buttonSpeed * dt
        elseif b.currentPos.x > b.finalePos.x then
            b.currentPos.x = b.finalePos.x
        end
    end
end

function checkButtonHover()
    local isHover = false
    for n = 1, #menu.buttonTexts do
        local b = menu.buttonTexts[n]
        if b.currentPos.x == b.finalePos.x then
            local mX, mY = love.mouse.getPosition()
            if mX < b.currentPos.x + menu.buttonWidth * .5 and mX > b.currentPos.x - menu.buttonWidth * .5 then
                if mY < b.currentPos.y + menu.buttonHeight * .5 and mY > b.currentPos.y - menu.buttonHeight * .5 then
                    b.isHover = true
                    isHover = true
                else
                    b.isHover = false
                end
            else
                b.isHover = false
            end
        else
            b.isHover = false
        end
    end
    if isHover then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
end

function menu.checkMousePressed(mX, mY, button)
    for n = 1, #menu.buttonTexts do
        local b = menu.buttonTexts[n]
        if b.currentPos.x == b.finalePos.x then
            if mX < b.currentPos.x + menu.buttonWidth * .5 and mX > b.currentPos.x - menu.buttonWidth * .5 then
                if mY < b.currentPos.y + menu.buttonHeight * .5 and mY > b.currentPos.y - menu.buttonHeight * .5 then
                    if button == 1 then
                        b.isClicked = true
                    else
                        b.isClicked = false
                    end
                else
                    b.isClicked = false
                end
            else
                b.isClicked = false
            end
        else
            b.isClicked = false
        end
    end
end

function menu.checkMouseRelease(mX, mY, button)
    for n = 1, #menu.buttonTexts do
        local b = menu.buttonTexts[n]
        if b.currentPos.x == b.finalePos.x then
            if mX < b.currentPos.x + menu.buttonWidth * .5 and mX > b.currentPos.x - menu.buttonWidth * .5 then
                if mY < b.currentPos.y + menu.buttonHeight * .5 and mY > b.currentPos.y - menu.buttonHeight * .5 then
                    if n == 1 and button == 1 and b.isClicked then
                        b.isClicked = false
                        b.isHover = false
                        scene = "game"
                        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
                    end
                end
            end
        end
    end
end

return menu
