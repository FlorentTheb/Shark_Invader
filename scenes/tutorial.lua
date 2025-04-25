local Tutorial = {}
local buttonFactory = require "factory/buttons"

function Tutorial.init()
    Tutorial.fonts = {
        medium = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 50),
        small = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 25)
    }
    Tutorial.steps = {
        {
            text = "Tourne avec les touches Q et D",
            isStepOK = false
        }
    }
    Tutorial.stepIndex = 1
    Tutorial.isOver = false
    Tutorial.skipButton = buttonFactory.createSingleButton("Skip", Tutorial.fonts.small, 60, 50, .3)
end

function Tutorial.updateStep()
    if Tutorial.isOver then
        return
    end

    local currentStep = Tutorial.steps[Tutorial.stepIndex]

    if Tutorial.stepIndex > #Tutorial.steps then
        Tutorial.isOver = true
    elseif currentStep and currentStep.isStepOK then
        Tutorial.stepIndex = Tutorial.stepIndex + 1
    end
end

function Tutorial.update(dt)
    Tutorial.updateStep()

    Tutorial.skipButton.update(false, nil, dt)
    if Tutorial.skipButton.state.isHover then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
end

function Tutorial.draw()
    Tutorial.skipButton.draw()
    love.graphics.push("all")
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.printf(Tutorial.steps[Tutorial.stepIndex].text, Tutorial.fonts.medium, love.graphics.getWidth() * .5, Tutorial.fonts.medium:getHeight(), Tutorial.fonts.medium:getWidth(Tutorial.steps[Tutorial.stepIndex].text), "left", 0, 1, 1, Tutorial.fonts.medium:getHeight() * .5, Tutorial.fonts.medium:getWidth(Tutorial.steps[Tutorial.stepIndex].text) * .5)
    love.graphics.pop()
end

function Tutorial.checkMousePressed()
    Tutorial.skipButton.mousePressed()
end

function Tutorial.reset()
    Tutorial.skipButton.reset(false)
    Tutorial.stepIndex = 1
    Tutorial.isOver = false
end

function Tutorial.checkMouseRelease()
    if Tutorial.skipButton.isClicked() then
        if Tutorial.skipButton.label.text == "Skip" then
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
            Tutorial.reset()
            return "game"
        end
    end
    return "tutorial"
end

return Tutorial
