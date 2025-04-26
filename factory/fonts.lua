local FontFactoryModule = {}

function FontFactoryModule.init()
    FontFactoryModule.fonts = {
        {
            giant = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 200),
            big = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 100),
            medium = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 50),
            small = love.graphics.newFont("assets/__fonts__/secret_thief.otf", 25)
        },
        {
            giant = love.graphics.newFont("assets/__fonts__/gloomie_saturday.otf", 200),
            big = love.graphics.newFont("assets/__fonts__/gloomie_saturday.otf", 100),
            medium = love.graphics.newFont("assets/__fonts__/gloomie_saturday.otf", 50),
            small = love.graphics.newFont("assets/__fonts__/gloomie_saturday.otf", 25)
        }
    }
end

function FontFactoryModule.getFont(index, size)
    return FontFactoryModule.fonts[index][size]
end

return FontFactoryModule