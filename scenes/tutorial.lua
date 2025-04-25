local Tutorial = {}

local buttonFactory = require "factory/buttons"
local Entity = require "objects/entity"
local Player = Entity.Player
local Projectile = require "objects/projectile"

function Tutorial.init()
    Tutorial.fonts = {
        medium = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 50),
        small = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 25)
    }
    Tutorial.steps = {
        {
            text = "Tourne vers la gauche avec Q",
            isStepOK = false
        },
        {
            text = "Tourne vers la droite avec D",
            isStepOK = false
        },
        {
            text = "Avance avec Z",
            isStepOK = false
        },
        {
            text = "Recule avec S",
            isStepOK = false
        },
        {
            text = "Tire en maintenant clic droit de la souris",
            isStepOK = false
        }
    }
    Tutorial.stepIndex = 1
    Tutorial.skipButton = buttonFactory.createSingleButton("Skip", Tutorial.fonts.small, 60, 50, .3)

    Tutorial.player = Player:create()
    Projectile:init()
end

function Tutorial.updateStep()
    local currentStep = Tutorial.steps[Tutorial.stepIndex]

    if currentStep and currentStep.isStepOK then
        currentStep.isStepOK = false
        Tutorial.stepIndex = Tutorial.stepIndex + 1
    end

    if Tutorial.stepIndex > #Tutorial.steps then
        return "game"
    end
    return "tutorial"
end

function Tutorial.update(dt)
    Tutorial.checkSteps(dt)
    local scene = Tutorial.updateStep()
    if scene == "game" then
        Tutorial.reset()
        return scene
    end
    Tutorial.player:update(dt)

    Tutorial.skipButton.update(false, nil, dt)
    if Tutorial.skipButton.state.isHover then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
    return scene
end

function Tutorial.checkSteps(dt)
    if love.keyboard.isDown("q") then
        Tutorial.player:turnLeft(dt)
        if Tutorial.stepIndex == 1 then
            Tutorial.steps[Tutorial.stepIndex].isStepOK = true
        end
    elseif love.keyboard.isDown("d") and Tutorial.stepIndex > 1 then
        Tutorial.player:turnRight(dt)
        if Tutorial.stepIndex == 2 then
            Tutorial.steps[Tutorial.stepIndex].isStepOK = true
        end
    end

    if love.keyboard.isDown("z") and Tutorial.stepIndex > 2 then
        Tutorial.player:move(dt, 1)
        if Tutorial.stepIndex == 3 then
            Tutorial.steps[Tutorial.stepIndex].isStepOK = true
        end
    elseif love.keyboard.isDown("s") and Tutorial.stepIndex > 3 then
        Tutorial.player:move(dt, -1)
        if Tutorial.stepIndex == 4 then
            Tutorial.steps[Tutorial.stepIndex].isStepOK = true
        end
    end

    if love.mouse.isDown(1) and Tutorial.stepIndex > 4 then
        Tutorial.player:newProjectile(2, dt)
        if Tutorial.stepIndex == 5 then
            Tutorial.steps[Tutorial.stepIndex].isStepOK = true
        end
    end
end

function Tutorial.draw()
    Tutorial.player:draw()

    Tutorial.skipButton.draw()
    love.graphics.push("all")
    love.graphics.setColor({.2, .2, 1, 1})

    local currentText = Tutorial.steps[Tutorial.stepIndex].text
    local posX = love.graphics.getWidth() * .5
    local posY = 2 * Tutorial.fonts.medium:getHeight()
    local oX = Tutorial.fonts.medium:getWidth(currentText) * .5
    local oY = Tutorial.fonts.medium:getHeight() * .5
    love.graphics.printf(currentText, Tutorial.fonts.medium, posX, posY, Tutorial.fonts.medium:getWidth(currentText), "left", 0, 1, 1, oX, oY)
    love.graphics.pop()
end

function Tutorial.checkMousePressed()
    Tutorial.skipButton.mousePressed()
end

function Tutorial.reset()
    Tutorial.skipButton.reset(false)
    Tutorial.stepIndex = 1
    Tutorial.isOver = false
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
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
