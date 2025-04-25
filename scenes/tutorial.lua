local Tutorial = {}

function Tutorial.init()
    Tutorial.steps = {
        {
            text = "Tourne sur toi avec les touches Q et D",
            isStepOK = false
        }
    }
    Tutorial.stepIndex = 1
    Tutorial.isOver = false
    Tutorial.font = love.graphics.newFont("assets/__fonts__/bubbles.ttf", 50)
end

function Tutorial:updateStep()
    if self.isOver then
        return
    end

    local currentStep = self.steps[self.stepIndex]

    if self.stepIndex > #self.steps then
        self.isOver = true
    elseif currentStep and currentStep.isStepOK then
        self.stepIndex = self.stepIndex + 1
    end
end

function Tutorial:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.steps[self.stepIndex].text, self.font, love.graphics.getWidth() * .5, self.font:getHeight(), self.font:getWidth(self.steps[self.stepIndex]), "left", 0, 1, 1, self.font:getHeight() * .5, self.font:getWidth(self.steps[self.stepIndex]) * .5)
end

return Tutorial
