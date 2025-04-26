local Tutorial = {}

local ButtonFactory = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

local Entity = require "objects/entity"
local Player = Entity.Player
local Projectile = require "objects/projectile"
local NextLevel = require "utils/nextLevel"

function Tutorial.new(player)
    Projectile.new()
    Tutorial.fonts = {
        medium = FontFactoryModule.getFont(1, "medium"),
        small = FontFactoryModule.getFont(1, "small")
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
            text = "Tire en maintenant clic gauche de la souris",
            isStepOK = false
        },
        {
            text = "Bonne chance !",
            isStepOK = false
        }
    }
    Tutorial.skipButton = ButtonFactory.createSingleButton("Skip", Tutorial.fonts.small, 60, 50, .3)
    Tutorial.player = player
end

function Tutorial.init()
    NextLevel.init()
    Projectile.init()
    Tutorial.projectiles = Projectile.projectilesTable
    Tutorial.stepIndex = 1
    Tutorial.isOver = false
    Tutorial.player.body.position.x = love.graphics.getWidth() * .5
    Tutorial.player.body.position.y = love.graphics.getHeight() * .5
    Tutorial.player.body.angle = 0
    for n = 1, #Tutorial.steps do
        Tutorial.steps[n].isStepOK = false
    end
    NextLevel.isVisible = false
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Tutorial.updateStep()
    local currentStep = Tutorial.steps[Tutorial.stepIndex]

    if currentStep and currentStep.isStepOK and Tutorial.stepIndex < #Tutorial.steps then
        Tutorial.stepIndex = Tutorial.stepIndex + 1
    elseif Tutorial.stepIndex == #Tutorial.steps then
        NextLevel.isVisible = true
    end
end

function Tutorial.updateProjectiles(dt)
    for n = #Tutorial.projectiles, 1, -1 do
        if Tutorial.projectiles[n].update(Tutorial.player, nil, dt) then
            table.remove(Tutorial.projectiles, n)
        end
    end
end

function Tutorial.drawProjectiles()
    for n = #Tutorial.projectiles, 1, -1 do
        Tutorial.projectiles[n].draw()
    end
end

function Tutorial.update(dt)
    if not Tutorial.isOver then
        Tutorial.checkSteps(dt)
    else
        if NextLevel.updateFading("end", dt) then
            return "Game"
        else
            return "Tutorial"
        end
    end

    Tutorial.updateStep()
    Tutorial.player:update(dt)

    Tutorial.skipButton.update(false, nil, dt)
    if Tutorial.skipButton.state.isHover then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
    Tutorial.updateProjectiles(dt)
    NextLevel.update(dt)
    return "Tutorial"
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

    if Tutorial.stepIndex == #Tutorial.steps then
        Tutorial.isOver = NextLevel.isInExit(Tutorial.player.body.position.x, Tutorial.player.body.position.y)
    end
end

function Tutorial.draw()
    NextLevel.drawExit()
    Tutorial.player:draw()
    Tutorial.drawProjectiles()

    NextLevel.drawArrow()

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
    if Tutorial.isOver then
        NextLevel.drawFading("end")
    end
end

function Tutorial.checkMousePressed()
    Tutorial.skipButton.mousePressed()
end

function Tutorial.checkMouseRelease()
    if Tutorial.skipButton.isClicked() then
        if Tutorial.skipButton.label.text == "Skip" then
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
            Tutorial.isOver = true
        end
    end
    return "Tutorial"
end

return Tutorial
