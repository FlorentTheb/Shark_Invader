local Settings = {}
local ButtonFactoryModule = require "factory/buttons"
local FontFactoryModule = require "factory/fonts"

function Settings.new()
    Settings.panel = {}
    Settings.panel.fonts = {
        button = FontFactoryModule.getFont(1, "big"),
        settings = FontFactoryModule.getFont(2, "medium")
    }
end

function Settings.init()
    
end

function Settings.update(dt)
    
end

function Settings.draw()
    
end

function Settings.checkMousePressed()
    for n = 1, #Settings.buttons do
        Settings.buttons[n].mousePressed()
    end
end

function Settings.checkMouseRelease()
    for n = 1, #Settings.buttons do
        if Settings.buttons[n].isClicked() then
            if Settings.buttons[n].label.text == "Back" then
                return "Settings"
            end
        end
    end
    return "Settings"
end

return Settings