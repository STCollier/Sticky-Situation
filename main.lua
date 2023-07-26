local sock = require "lib/sock"

local menu = require "scripts/menu"
local gamestate = require "scripts/gamestate"
local player = require "scripts/player"
local map = require "scripts/map"
local cam = require "lib/camera"

local allPlayers = {}

function table.removekey(table, key)
   local element = table[key]
   table[key] = nil
   return element
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function drawPlayer(name, x, y)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(name, x - 250, y - 75*1.5, 500, "center")

    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.circle("fill", x, y, 50)
end

-- client.lua
function love.load()
    love.graphics.setBackgroundColor(1, 1, 1, 1)

    camera = cam()

    client = sock.newClient("localhost", 8080)

    love.physics.setMeter(64)
    gamestate.world = love.physics.newWorld(0, 9.81*64, true)
    gamestate.world:setCallbacks(beginContact)

    love.graphics.setDefaultFilter("nearest", "nearest")

    menu:load()
    map:load()

    client:on("disconnect", function(data)
        client:on("leaveGame", function(data)
            gamestate.numPlayers = data.numPlayers
        end)
    end)

    client:on("joinGame", function(data)
        print(data.username.." joined")
        gamestate.numPlayers = data.numPlayers
    end)

    client:on("playerData", function(data)
        allPlayers = data
    end)

    client:connect()
end

function love.update(dt)
    client:update()
    
    if (gamestate.scene == "menu") then menu:update(client) end
    if (gamestate.scene == "game") then
        gamestate.world:update(dt)
        player:update(client, dt)

        for key, v in pairs(allPlayers) do
            print(allPlayers[key].username, allPlayers[key].x, allPlayers[key].y)
        end
    end
end

function love.draw()
    if (gamestate.scene == "menu") then menu:draw() end
    if (gamestate.scene == "game") then
        camera:attach()
        for key, v in pairs(allPlayers) do
            if (allPlayers[key].username ~= menu.input.username) then
                drawPlayer(allPlayers[key].username, allPlayers[key].x, allPlayers[key].y)
            else
                player:draw()
            end
        end

        love.graphics.setColor(1, 1, 1, 1)
        map:draw()
        camera:detach()
    end
end 


function beginContact(a, b)
    player:resetJump(a, b)
end