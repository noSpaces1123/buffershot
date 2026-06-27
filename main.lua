---@diagnostic disable: lowercase-global


VersionNr = "0.1"


zutil = require "zutil"

NameOfTheGame = "buffershot"
zutil.standardinitialization(0, 0, NameOfTheGame, { fullscreen = true, highdpi = true })

require "player"
require "particle"


function love.load()
    love.graphics.setBackgroundColor(1,1,1)

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    DoPlayerMovement()
    UpdateParticles()
end

function love.draw()
    DrawBGParticles()

    DrawPlayer()

    DrawParticles()
end