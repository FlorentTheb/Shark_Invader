SoundManager = {}
local Settings = require "scenes/settings"

function SoundManager.new()
    SoundManager.music = love.audio.newSource("assets/__sounds__/relaxing_music.ogg", "stream")
    SoundManager.click = love.audio.newSource("assets/__sounds__/click.ogg", "static")
    SoundManager.victory = love.audio.newSource("assets/__sounds__/victory.ogg", "static")
    SoundManager.lose = love.audio.newSource("assets/__sounds__/lose.ogg", "static")
    SoundManager.bubble = {
        love.audio.newSource("assets/__sounds__/big_bubble.ogg", "static"),
        love.audio.newSource("assets/__sounds__/small_bubble.ogg", "static")
    }
end

function SoundManager.update()
    SoundManager.music:setVolume(Settings.conf[3].slider.value)
    for n = 1, #SoundManager.bubble do
        SoundManager.bubble[n]:setVolume(Settings.conf[4].slider.value)
    end
    SoundManager.click:setVolume(Settings.conf[4].slider.value)
    SoundManager.victory:setVolume(Settings.conf[4].slider.value)
    SoundManager.lose:setVolume(Settings.conf[4].slider.value)
end
