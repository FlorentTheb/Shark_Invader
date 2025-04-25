local NextLevel = {}

function NextLevel.init()
    NextLevel.isVisible = false
    NextLevel.arrow = {}
    NextLevel.arrow.img = love.graphics.newImage("assets/__images__/arrow.png")
    NextLevel.arrow.color = {1, 1, 1, 1}
    NextLevel.arrow.origin = {
        x = NextLevel.arrow.img:getWidth() * .5,
        y = NextLevel.arrow.img:getHeight() * .5
    }
    NextLevel.arrow.shadow = {
        color = {0, 0, 0, .2},
        offset = {
            x = 5,
            y = 5
        }
    }

    NextLevel.exit = {}
    NextLevel.exit.size = {
        width = 200,
        height = 300
    }
    NextLevel.exit.position = {
        x = 0 - NextLevel.exit.size.width * .5,
        y = love.graphics.getHeight() * .5 - NextLevel.exit.size.height * .5
    }
    NextLevel.exit.color = {1, 1, 1, .2}

    NextLevel.arrow.position = {
        x = NextLevel.exit.size.width * .5 + NextLevel.arrow.img:getWidth() * .5,
        y = NextLevel.exit.position.y + NextLevel.exit.size.height * .5
    }
    NextLevel.arrow.treshold = .7
    NextLevel.arrow.vector = 1
    NextLevel.arrow.speed = 20
    NextLevel.currentTime = 0
end

function NextLevel.update(dt)
    NextLevel.arrow.position.x = NextLevel.arrow.position.x + dt * NextLevel.arrow.speed * NextLevel.arrow.vector
    NextLevel.currentTime = NextLevel.currentTime + dt
    if NextLevel.currentTime > NextLevel.arrow.treshold then
        NextLevel.currentTime = 0
        NextLevel.arrow.vector = -NextLevel.arrow.vector
    end
end

function NextLevel.drawExit()
    if NextLevel.isVisible then
        love.graphics.push("all")
        love.graphics.setColor(NextLevel.exit.color)
        love.graphics.rectangle("fill", NextLevel.exit.position.x, NextLevel.exit.position.y, NextLevel.exit.size.width, NextLevel.exit.size.height, 10, 10)
        love.graphics.pop()
    end
end

function NextLevel.drawArrow()
    if NextLevel.isVisible then
        love.graphics.push("all")
        love.graphics.setColor(NextLevel.arrow.shadow.color)
        love.graphics.draw(NextLevel.arrow.img, NextLevel.arrow.position.x + NextLevel.arrow.shadow.offset.x, NextLevel.arrow.position.y + NextLevel.arrow.shadow.offset.y, 0, 1, 1, NextLevel.arrow.origin.x, NextLevel.arrow.origin.y)
        love.graphics.setColor(NextLevel.arrow.color)
        love.graphics.draw(NextLevel.arrow.img, NextLevel.arrow.position.x, NextLevel.arrow.position.y, 0, 1, 1, NextLevel.arrow.origin.x, NextLevel.arrow.origin.y)
        love.graphics.pop()
    end
end

return NextLevel
