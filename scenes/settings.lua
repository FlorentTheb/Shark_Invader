local Settings = {}
local ButtonFactoryModule = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Settings.new()
    Settings.fonts = {
        FontFactoryModule.getFont(1, "medium"),
        FontFactoryModule.getFont(2, "small")
    }
    Settings.title = {
        text = "Options"
    }
    Settings.panelWidth = love.graphics.getWidth() * .5
    Settings.panelHeight = love.graphics.getHeight() * .8
    Settings.panelBorderSize = Settings.panelWidth * .05
    Settings.panelAnimationSpeed = 900
    Settings.borderColor = {0, .5, .5, 1}
    Settings.panelColor = {0.6, 0.8, 1, .9}
    Settings.conf = {
        {
            label = {
                text = "Mode plein ecran",
                position = {
                    x,
                    y
                }
            },
            toggle = {
                position = {
                    x,
                    y
                },
                toggleSize = 20,
                toggleCheckedSize = 16,
                isToggled = love.window.getFullscreen(),
                isHover = false
            }
        },
        {
            label = {
                text = "Volume musique",
                position = {
                    x,
                    y
                }
            },
            slider = {
                position = {
                    x,
                    y
                },
                width = 50,
                toggleSize = 10,
                value = 16,
                isDragged = false
            }
        },
        {
            label = {
                text = "Volume SFX",
                position = {
                    x,
                    y
                }
            },
            slider = {
                position = {
                    x,
                    y
                },
                width = 50,
                toggleSize = 10,
                value = 16,
                isDragged = false
            }
        }
    }
    Settings.returnButton = ButtonFactoryModule.createSingleButton(Settings.fonts[2], "Retour")
end

function Settings.init()
    Settings.isVisible = false
    Settings.panelPosition = {
        x = love.graphics.getWidth() * .5,
        y = love.graphics.getHeight() + Settings.panelHeight * .5
    }
    Settings.isPanelFadingIn = true
    Settings.isPanelFadingOut = false

    Settings.returnButton.update(Settings.panelPosition.x, Settings.panelPosition.y + Settings.panelHeight * .5 - Settings.panelBorderSize - Settings.returnButton.height * .5, nil, nil, dt)
    Settings.returnButton.state.isAtStart = false
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function Settings.update(dt)
    Settings.movePanel(dt)

    Settings.title.position = {
        x = Settings.panelPosition.x,
        y = Settings.panelPosition.y - Settings.panelHeight * .5 + Settings.panelBorderSize + Settings.fonts[1]:getHeight() * .5
    }

    Settings.updateSettings()
    Settings.isFullScreenToggleHover()

    Settings.returnButton.update(Settings.panelPosition.x, Settings.panelPosition.y + Settings.panelHeight * .5 - Settings.panelBorderSize - Settings.returnButton.height * .5, nil, nil, false, dt)
    
    if Settings.returnButton.state.isHover or Settings.conf[1].toggle.isHover then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
    return "Settings"
end

function Settings.movePanel(dt)
    local yCenter = love.graphics.getHeight() * .5
    local yOut = -Settings.panelHeight * .5
    local currentPos = Settings.panelPosition
    if Settings.isPanelFadingIn then
        if currentPos.y == yCenter then
            Settings.isPanelFadingIn = false
        elseif currentPos.y > yCenter then
            currentPos.y = currentPos.y - dt * Settings.panelAnimationSpeed
        else
            currentPos.y = yCenter
        end
    elseif Settings.isPanelFadingOut then
        if currentPos.y == yOut then
            Settings.init()
        elseif currentPos.y > yOut then
            currentPos.y = currentPos.y - dt * Settings.panelAnimationSpeed
        else
            currentPos.y = yOut
        end
    end
end

function Settings.updateSettings()
    for n = 1, #Settings.conf do
        local elementPos
        local label = Settings.conf[n].label
        label.position.x = Settings.panelPosition.x - Settings.panelWidth * .5 + Settings.panelBorderSize * 3
        label.position.y = Settings.panelPosition.y + (n - 2) * Settings.fonts[2]:getHeight() * 3
        if n == 1 then
            elementPos = Settings.conf[n].toggle.position
            Settings.conf[n].toggle.isToggled = love.window.getFullscreen()
        else
            elementPos = Settings.conf[n].slider.position
        end
        elementPos.x = Settings.panelPosition.x + Settings.panelWidth * .25
        elementPos.y = label.position.y + Settings.fonts[2]:getHeight() * .5
    end
end

function Settings.displaySetting()
    for n = 1, #Settings.conf do
        local toggle
        local label = Settings.conf[n].label
        love.graphics.printf(label.text, Settings.fonts[2], label.position.x, label.position.y, Settings.fonts[2]:getWidth(label.text), "left", 0, 1, 1, 0, 0)
        if n == 1 then
            toggle = Settings.conf[n].toggle
            love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleSize)
            if toggle.isToggled then
                love.graphics.push("all")
                love.graphics.setColor(Settings.borderColor)
                love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleCheckedSize)
                love.graphics.pop()
            end

            if toggle.isHover then
                love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, .2)
                love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleCheckedSize)
                love.graphics.pop()
            end
        else
        end
    end
end

function Settings.draw()
    love.graphics.push("all")

    Settings.drawPanel()

    local title = Settings.title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(title.text, Settings.fonts[1], title.position.x, title.position.y, Settings.fonts[1]:getWidth(title.text), "left", 0, 1, 1, Settings.fonts[1]:getWidth(title.text) * .5, Settings.fonts[1]:getHeight() * .5)

    Settings.displaySetting()

    Settings.returnButton.draw()

    love.graphics.pop()
end

function Settings.drawPanel()
    local currentPos = Settings.panelPosition

    love.graphics.setColor(Settings.panelColor)
    love.graphics.rectangle("fill", currentPos.x - Settings.panelWidth * .5, currentPos.y - Settings.panelHeight * .5, Settings.panelWidth, Settings.panelHeight, 10, 10)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(Settings.panelBorderSize)
    love.graphics.rectangle("line", currentPos.x - Settings.panelWidth * .5, currentPos.y - Settings.panelHeight * .5, Settings.panelWidth, Settings.panelHeight, 10, 10)

    love.graphics.setColor(Settings.borderColor)
    love.graphics.setLineWidth(Settings.panelBorderSize * .8)
    love.graphics.rectangle("line", currentPos.x - Settings.panelWidth * .5, currentPos.y - Settings.panelHeight * .5, Settings.panelWidth, Settings.panelHeight, 10, 10)
end

function Settings.isFullScreenToggleHover()
    local mX, mY = love.mouse.getPosition()
    local pX = Settings.conf[1].toggle.position.x
    local pY = Settings.conf[1].toggle.position.y
    local radius = Settings.conf[1].toggle.toggleSize
    local dX = mX - pX
    local dY = mY - pY
    Settings.conf[1].toggle.isHover = dX * dX + dY * dY <= radius * radius
end

function Settings.checkMousePressed()
    Settings.returnButton.mousePressed()
end

function Settings.checkMouseRelease()
    if Settings.returnButton.isClicked() then
        if Settings.returnButton.label.text == "Retour" then
            Settings.isPanelFadingOut = true
        end
    elseif Settings.conf[1].toggle.isHover then
        love.window.setFullscreen(not Settings.conf[1].toggle.isToggled)
        Settings.panelWidth = love.graphics.getWidth() * .5
        Settings.panelHeight = love.graphics.getHeight() * .8
        Settings.panelPosition.x = love.graphics.getWidth() * .5
        Settings.panelPosition.y = love.graphics.getHeight() * .5
        love.mouse.setPosition(Settings.panelPosition.x, Settings.panelPosition.y)
    end
end

return Settings
