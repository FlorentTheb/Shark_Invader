--[[   -Buttons- FACTORY
    This module give several functionalities :
    - Create a single button at a given coordinate (center of the button), with a given alpha for the transparency
    - Create multiple buttons aligned with themselves :
        > A given arg set if the alignement should be horizontal or vertical : 
            horizontal set the buttons side to side (bottom of screen)
            vertical set the buttons in a row (middle of the screen)
        > All buttons of the list will have the same size, which is set according to the longest label
    - These methods yet need the specific font initially
]]
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
        maxWidth = math.max(maxWidth, math.floor(font:getWidth(l))) -- Update if the current label is longer than the previous ones
    end
    return maxWidth
end

local function createButton(indexButton, totalButtons, currentLabel, font, isHorizontalDisplayed, labelWidth, posX, posY)
    local button = {}
    button.padding = 20
    button.margin = 20
    if labelWidth then -- Condition to know if its a simple button or a list that is currently created
        button.width = labelWidth + 2 * button.padding
    else
        button.width = font:getWidth(currentLabel) + 2 * button.padding
    end
    local alphaShadow
    if indexButton then
        alphaShadow = .3
    else
        alphaShadow = 0
    end
    button.height = font:getHeight() + 2 * button.padding
    button.cornerRatio = 10
    button.shadow = {
        offset = 5,
        color = {0, 0, 0, alphaShadow}
    }
    button.color = {0, .5, .5, 1}
    button.position = {}
    if posX and posY then
        button.position.finale = {
            x = posX,
            y = posY
        }
        button.position.current = {
            x = posX,
            y = posY
        }
    else
        local xOrigin = love.graphics.getWidth() * .5 - (totalButtons - 1) * ((button.width + button.margin) * .5)
        local yOrigin = love.graphics.getHeight() * .5 - (totalButtons - 1) * ((button.height + button.margin) * .5)
        -- The finale position, the inital position and the direction will depend on where the buttons will be in the end

        button.position.finale = {
            x = isHorizontalDisplayed and xOrigin + (button.width + button.margin) * (indexButton - 1) or love.graphics.getWidth() * .5,
            y = isHorizontalDisplayed and love.graphics.getHeight() * .7 or yOrigin + (button.height + button.margin) * (indexButton - 1)
        }
        button.position.current = {
            x = isHorizontalDisplayed and button.position.finale.x or -button.width,
            y = isHorizontalDisplayed and love.graphics.getHeight() + button.height or button.position.finale.y
        }
        button.vector = {
            x = isHorizontalDisplayed and 0 or 1, -- We move X wise only if set as final display vertical (buttons come from left to right)
            y = isHorizontalDisplayed and -1 or 0 -- We move Y wise only if set as final display horizontal (buttons come from bottom to upper)
        }
    end
    button.state = {isHover = false, isClicked = false}
    button.label = createLabel(font, currentLabel)

    function button.reset(isHorizontalDisplayed) -- Reset the button at its initial location to redo the animation if the scene is restarted
        if not posX or not posY then
            local xOrigin = love.graphics.getWidth() * .5 - (totalButtons - 1) * ((button.width + button.margin) * .5)
            local yOrigin = love.graphics.getHeight() * .5 - (totalButtons - 1) * ((button.height + button.margin) * .5)
            button.position.finale = {
                x = isHorizontalDisplayed and xOrigin + (button.width + button.margin) * (indexButton - 1) or love.graphics.getWidth() * .5,
                y = isHorizontalDisplayed and love.graphics.getHeight() * .7 or yOrigin + (button.height + button.margin) * (indexButton - 1)
            }
            button.position.current = {
                x = isHorizontalDisplayed and button.position.finale.x or -button.width,
                y = isHorizontalDisplayed and love.graphics.getHeight() + button.height or button.position.finale.y
            }
            button.state.isHover = false
            button.state.isClicked = false
        end
    end

    function button.isClicked()
        if button.isMouseIn() and button.state.isClicked then -- Confirm with this method that the release of the mouse is on the same button as the click
            return true
        else
            return false
        end
    end

    function button.mousePressed()
        if button.isMouseIn() then
            button.state.isClicked = true -- Only for the press of mouse button. We wait for the release to process (cf isClicked method)
        else
            button.state.isClicked = false
        end
    end

    function button.isMouseIn() -- True if mouse is IN button and it has stopped animate (reached its final position)
        local mX, mY = love.mouse.getPosition()
        local rightBorderButton = button.position.current.x + button.width * .5
        local leftBorderButton = button.position.current.x - button.width * .5
        local lowerBorderButton = button.position.current.y + button.height * .5
        local upperBorderButton = button.position.current.y - button.height * .5

        local isInXWise = mX <= rightBorderButton and mX >= leftBorderButton
        local isInYWise = mY <= lowerBorderButton and mY >= upperBorderButton
        local isButtonNotMoving = button.position.current.x == button.position.finale.x and button.position.current.y == button.position.finale.y

        if isButtonNotMoving and isInXWise and isInYWise then
            return true
        else
            return false
        end
    end

    function button.update(hasToMove, animationSpeed, dt)
        local current = button.position.current
        local finale = button.position.finale
        if hasToMove then
            if (current.x < finale.x or current.y > finale.y) then -- Vector set in the creation -> set the direction of the button
                current.x = current.x + animationSpeed * button.vector.x * dt
                current.y = current.y + animationSpeed * button.vector.y * dt
            elseif current.x > finale.x or current.y < finale.y then
                current.x = finale.x
                current.y = finale.y
            end
        end

        if button.isMouseIn() then -- Hover with mouse
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

function ButtonFactoryModule.createButtonList(listButtonsLabel, font, isHorizontalDisplayed)
    local listButton = {}
    local labelWidth = getMaxWidthLabels(listButtonsLabel, font) -- Already get the width of the longest label
    for n = 1, #listButtonsLabel do
        local button = createButton(n, #listButtonsLabel, listButtonsLabel[n], font, isHorizontalDisplayed, labelWidth)

        table.insert(listButton, button)
    end

    return listButton
end

function ButtonFactoryModule.createSingleButton(label, font, posX, posY)
    return createButton(nil, nil, label, font, nil, nil, posX, posY)
end

return ButtonFactoryModule
