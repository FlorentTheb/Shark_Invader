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

local function createButton(font, label, width)
    local button = {}
    button.speed = 900
    button.padding = 20
    button.margin = 40
    button.width = width + 2 * button.padding
    button.height = font:getHeight() + 2 * button.padding
    button.cornerRatio = 10
    button.shadow = {
        offset = 5,
        color = {0, 0, 0, .3}
    }
    button.color = {0, .5, .5, 1}
    button.position = {
        initial = {},
        final = {},
        current = {}
    }
    button.hasToMove = false

    button.state = {isHover = false, isClicked = false, isMoving = false, isAtStart = true}
    button.label = createLabel(font, label)

    function button.isClicked()
        if button.isMouseIn() and button.state.isClicked then -- Confirm with this method that the release of the mouse is on the same button as the click
            SoundManager.click:stop()
            SoundManager.click:play()
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
        local isButtonOkToInteract = not button.state.isMoving and not button.state.isAtStart

        if isButtonOkToInteract and isInXWise and isInYWise then
            return true
        else
            return false
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

    function button.update(finalX, finalY, indexButton, nbButton, hoverDisabled, dt)
        if finalX and finalY then -- Static button
            button.position.current.x = finalX
            button.position.current.y = finalY
            button.position.final = button.position.current
            button.position.initial = button.position.current
        elseif finalX then -- button in vertical list
            button.position.final.x = finalX
            button.position.initial.x = -button.width
            if button.state.isAtStart then
                button.position.current.x = button.position.initial.x
            end
            if button.state.isMoving then
                button.state.isAtStart = false
                if button.position.current.x >= button.position.final.x then
                    button.position.current.x = button.position.final.x
                    button.state.isMoving = false
                else
                    button.position.current.x = button.position.current.x + dt * button.speed
                end
            end
            if not button.state.isAtStart and not button.state.isMoving then
                button.position.current.x = button.position.final.x
            end
            local yOrigin = love.graphics.getHeight() * .5 - (nbButton - 1) * ((button.height + button.margin) * .5)
            button.position.current.y = yOrigin + (button.height + button.margin) * (indexButton - 1)
            button.position.final.y = button.position.current.y
            button.position.initial.y = button.position.current.y
        else -- button in horizontal list
            button.position.final.y = finalY
            button.position.initial.y = love.graphics.getHeight() + button.height
            if button.state.isAtStart then
                button.position.current.y = button.position.initial.y
            end
            if button.state.isMoving then
                button.state.isAtStart = false
                if button.position.current.y <= button.position.final.y then
                    button.position.current.y = button.position.final.y
                    button.state.isMoving = false
                else
                    button.position.current.y = button.position.current.y - dt * button.speed
                end
            end
            if not button.state.isAtStart and not button.state.isMoving then
                button.position.current.y = button.position.final.y
            end
            local xOrigin = love.graphics.getWidth() * .5 - (nbButton - 1) * ((button.width + button.margin) * .5)
            button.position.current.x = xOrigin + (button.width + button.margin) * (indexButton - 1)
            button.position.final.x = button.position.current.x
            button.position.initial.x = button.position.current.x
        end

        if button.isMouseIn() and not hoverDisabled then -- Hover with mouse
            button.color = {0, .7, .7, 1}
            button.state.isHover = true
        else
            button.color = {0, .5, .5, 1}
            button.state.isHover = false
        end
    end

    return button
end

function ButtonFactoryModule.createButtonList(listButtonsLabel, font)
    local listButton = {}
    local labelWidth = getMaxWidthLabels(listButtonsLabel, font) -- Already get the width of the longest label
    for n = 1, #listButtonsLabel do
        local button = createButton(font, listButtonsLabel[n], labelWidth)
        table.insert(listButton, button)
    end

    return listButton
end

function ButtonFactoryModule.createSingleButton(font, label)
    return createButton(font, label, font:getWidth(label))
end

return ButtonFactoryModule
