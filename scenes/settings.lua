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
    Settings.panelWidth = love.graphics.getWidth() * .6
    Settings.panelHeight = love.graphics.getHeight() * .8
    Settings.panelBorderSize = Settings.panelWidth * .05
    Settings.panelAnimationSpeed = 1200
    Settings.borderColor = {0, .5, .5, 1}
    Settings.panelColor = {0.6, 0.8, 1, .95}
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
                text = "Passer tutoriel",
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
                isToggled = false,
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
                width = 150,
                height = 5,
                toggleSize = 10,
                value = .5,
                isDragged = false,
                isHover = false
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
                width = 150,
                height = 5,
                toggleSize = 10,
                value = .5,
                isDragged = false,
                isHover = false
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
    Settings.isToggleHover(1)
    Settings.isToggleHover(2)
    Settings.sliderHovered(3)
    Settings.sliderHovered(4)

    Settings.returnButton.update(Settings.panelPosition.x, Settings.panelPosition.y + Settings.panelHeight * .5 - Settings.panelBorderSize - Settings.returnButton.height * .5, nil, nil, false, dt)

    if Settings.returnButton.state.isHover or Settings.conf[1].toggle.isHover or Settings.conf[2].toggle.isHover or Settings.conf[3].slider.isHover or Settings.conf[4].slider.isHover then
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

local function roundTo(n, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(n * power + 0.5) / power
end

function Settings.updateSettings()
    for n = 1, #Settings.conf do
        local elementPos
        local label = Settings.conf[n].label
        label.position.x = Settings.panelPosition.x - Settings.panelWidth * .5 + Settings.panelBorderSize * 3
        label.position.y = Settings.panelPosition.y + (n - 2) * Settings.fonts[2]:getHeight() * 3
        if n <= 2 then
            elementPos = Settings.conf[n].toggle.position
        else
            local slider = Settings.conf[n].slider
            if slider.isDragged then
                local mX = love.mouse.getX()
                local relativeX = math.max(0, math.min(mX - (slider.position.x - slider.width * .5), slider.width))
                slider.value = relativeX / slider.width
                slider.value = roundTo(slider.value, 2)
            end
            elementPos = slider.position
        end
        elementPos.x = Settings.panelPosition.x + Settings.panelWidth * .25
        elementPos.y = label.position.y + Settings.fonts[2]:getHeight() * .5
    end
end

function Settings.displaySetting()
    for n = 1, #Settings.conf do
        local label = Settings.conf[n].label
        love.graphics.printf(label.text, Settings.fonts[2], label.position.x, label.position.y, Settings.fonts[2]:getWidth(label.text), "left", 0, 1, 1, 0, 0)
        if n <= 2 then
            local toggle = Settings.conf[n].toggle
            love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleSize)
            if Settings.conf[n].toggle.isToggled then
                love.graphics.push("all")
                love.graphics.setColor(Settings.borderColor)
                love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleCheckedSize)
                love.graphics.pop()
            end

            if Settings.conf[n].toggle.isHover then
                love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, .2)
                love.graphics.circle("fill", toggle.position.x, toggle.position.y, toggle.toggleCheckedSize)
                love.graphics.pop()
            end
        else
            local slider = Settings.conf[n].slider
            love.graphics.push("all")
            love.graphics.setColor(Settings.borderColor)
            love.graphics.rectangle("fill", slider.position.x - slider.width * .5, slider.position.y - slider.height * .5, slider.width, slider.height)

            local thumbX = slider.position.x - slider.width * .5 + slider.value * slider.width
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.circle("fill", thumbX, slider.position.y, slider.toggleSize)

            local sliderValueString = math.floor(slider.value * 100 + 0.5) .. "%"
            love.graphics.printf(sliderValueString, Settings.fonts[2], slider.position.x + slider.width * .5 + Settings.fonts[2]:getWidth(sliderValueString), slider.position.y, Settings.fonts[2]:getWidth(sliderValueString), "center", 0, 1, 1, Settings.fonts[2]:getWidth(sliderValueString) * .5, Settings.fonts[2]:getHeight() * .6)

            love.graphics.pop()
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

function Settings.isToggleHover(index)
    local mX, mY = love.mouse.getPosition()
    local pX = Settings.conf[index].toggle.position.x
    local pY = Settings.conf[index].toggle.position.y
    local radius = Settings.conf[index].toggle.toggleSize
    local dX = mX - pX
    local dY = mY - pY
    Settings.conf[index].toggle.isHover = dX * dX + dY * dY <= radius * radius
end

function Settings.sliderHovered(sliderIndex)
    local slider = Settings.conf[sliderIndex].slider
    local mX, mY = love.mouse.getPosition()
    local thumbX = slider.position.x - slider.width * .5 + slider.value * slider.width
    local thumbY = slider.position.y
    local dX = mX - thumbX
    local dY = mY - thumbY
    if dX * dX + dY * dY <= slider.toggleSize * slider.toggleSize then
        slider.isHover = true
    else
        slider.isHover = false
    end
end

function Settings.checkMousePressed()
    Settings.returnButton.mousePressed()
    if Settings.conf[3].slider.isHover then
        Settings.conf[3].slider.isDragged = true
    end
    if Settings.conf[4].slider.isHover then
        Settings.conf[4].slider.isDragged = true
    end
end

function Settings.checkMouseRelease()
    if Settings.returnButton.isClicked() then
        if Settings.returnButton.label.text == "Retour" then
            Settings.isPanelFadingOut = true
        end
    elseif Settings.conf[1].toggle.isHover then
        love.window.setFullscreen(not Settings.conf[1].toggle.isToggled)
        Settings.conf[1].toggle.isToggled = not Settings.conf[1].toggle.isToggled
        Settings.panelWidth = love.graphics.getWidth() * .6
        Settings.panelHeight = love.graphics.getHeight() * .8
        Settings.panelPosition.x = love.graphics.getWidth() * .5
        Settings.panelPosition.y = love.graphics.getHeight() * .5
        love.mouse.setPosition(Settings.panelPosition.x, Settings.panelPosition.y)
    elseif Settings.conf[2].toggle.isHover then
        Settings.conf[2].toggle.isToggled = not Settings.conf[2].toggle.isToggled
    end
    Settings.conf[3].slider.isDragged = false
    Settings.conf[4].slider.isDragged = false
end

return Settings
