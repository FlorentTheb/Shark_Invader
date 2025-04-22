local ButtonFactoryModule = {}

local function createLabel(font, text)
    local label = {}
    local fontUpperSpace = font:getHeight() * .125 -- Espace entre le haut de l'écriture et le haut de la font (1/8ème)
    label.font = font
    label.text = text
    label.origin = {
        x = font:getWidth(text) * .5,
        y = fontUpperSpace + (font:getAscent() - fontUpperSpace) * .5 -- on prend l'ascent pour ne pas tenir compte de l'espace sous l'écriture
    }
    label.angle = 0
    label.size = 1
    return label
end

local function getMaxWidthLabels(listButtonsLabel, font)
    local maxWidth = 0
    for n = 1, #listButtonsLabel do
        local l = listButtonsLabel[n]
        maxWidth = math.max(maxWidth, math.floor(font:getWidth(l)))
    end
    return maxWidth
end

local function createButton(indexButton, totalButtons, currentLabel, font, isHorizontal, labelWidth)
    local button = {}
    button.padding = 20
    button.margin = 20
    button.width = labelWidth + 2 * button.padding
    button.height = font:getHeight() + 2 * button.padding
    button.cornerRatio = 10
    button.shadow = {
        offset = 5,
        color = {0, 0, 0, .3}
    }
    button.color = {0, .5, .5, 1}
    button.position = {}
    local xOrigin = love.graphics.getWidth() * .5 - (totalButtons - 1) * ((button.width + button.margin) * .5)
    local yOrigin = love.graphics.getHeight() * .5 - (totalButtons - 1) * ((button.height + button.margin) * .5)
    button.position.finale = {
        x = isHorizontal and xOrigin + (button.width + button.margin) * (indexButton - 1) or love.graphics.getWidth() * .5,
        y = isHorizontal and love.graphics.getHeight() * .7 or yOrigin + (button.height + button.margin) * (indexButton - 1)
    }
    button.position.current = {
        x = isHorizontal and button.position.finale.x or -button.width,
        y = isHorizontal and love.graphics.getHeight() + button.height or button.position.finale.y
    }
    button.vector = {
        x = isHorizontal and 0 or 1,
        y = isHorizontal and -1 or 0
    }
    button.state = {isHover = false, isClicked = false}
    button.label = createLabel(font, currentLabel)

    function button.isClicked()
        if button.isMouseIn() and button.state.isClicked then
            return true
        else
            return false
        end
    end

    function button.mousePressed()
        if button.isMouseIn() then
            button.state.isClicked = true
        else
            button.state.isClicked = false
        end
    end

    function button.isMouseIn()
        local mX, mY = love.mouse.getPosition()
        local rightBorderButton = button.position.current.x + button.width * .5
        local leftBorderButton = button.position.current.x - button.width * .5
        local lowerBorderButton = button.position.current.y + button.height * .5
        local upperBorderButton = button.position.current.y - button.height * .5

        local isInXWise = mX <= rightBorderButton and mX >= leftBorderButton
        local isInYWise = mY <= lowerBorderButton and mY >= upperBorderButton
        local isButtonNotMoving = button.position.current.x == button.position.finale.x

        if isButtonNotMoving and isInXWise and isInYWise then
            return true
        else
            return false
        end
    end

    function button.update(hasToMove, animationSpeed, dt)
        local current = button.position.current
        local finale = button.position.finale

        if (current.x < finale.x or current.y > finale.y) and hasToMove then
            current.x = current.x + animationSpeed * button.vector.x * dt
            current.y = current.y + animationSpeed * button.vector.y * dt
        elseif current.x > finale.x or current.y < finale.y then
            current.x = finale.x
            current.y = finale.y
        end

        if button.isMouseIn() then
            button.color = {0, .7, .7, 1}
            button.state.isHover = true
        else
            button.color = {0, .5, .5, 1}
            button.state.isHover = false
        end
    end

    function button.draw()
        local buttonTopLeftX = button.position.current.x - button.width * .5
        local buttonTopLeftY = button.position.current.y - button.height * .5

        love.graphics.push("all")

        -- Shadow of button
        love.graphics.setColor(button.shadow.color)
        love.graphics.rectangle("fill", buttonTopLeftX + button.shadow.offset, buttonTopLeftY + button.shadow.offset, button.width, button.height, button.cornerRatio, button.cornerRatio)

        -- Actual button
        love.graphics.setColor(button.color)
        love.graphics.rectangle("fill", buttonTopLeftX, buttonTopLeftY, button.width, button.height, button.cornerRatio, button.cornerRatio)

        -- Button label
        love.graphics.setColor({1, 1, 1})
        love.graphics.printf(button.label.text, button.label.font, button.position.current.x, button.position.current.y, button.width, "left", button.label.angle, button.label.size, button.label.size, button.label.origin.x, button.label.origin.y)

        love.graphics.pop()
    end

    return button
end

function ButtonFactoryModule.createButtonList(listButtonsLabel, font, isHorizontal)
    local listButton = {}
    local labelWidth = getMaxWidthLabels(listButtonsLabel, font)
    for n = 1, #listButtonsLabel do
        local button = createButton(n, #listButtonsLabel, listButtonsLabel[n], font, isHorizontal, labelWidth)

        table.insert(listButton, button)
    end

    return listButton
end

return ButtonFactoryModule
