local sock = require "lib/sock"

local menu = require "scripts/menu"
local gamestate = require "scripts/gamestate"
local player = require "scripts/player"

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

--[[function drawPlayer(name, x, y)
    clients.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    clients.shape = love.physics.newCircleShape(50)
    clients.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(name, x - 250, y - 75*1.5, 500, "center")

    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.circle("fill", x, y, 50)
end]]

function addClient(name)
    allPlayers[name] = {}

    allPlayers[name].x = love.graphics.getWidth() / 2
    allPlayers[name].y = 100
    allPlayers[name].username = name
    allPlayers[name].body = love.physics.newBody(gamestate.world, x, y, "dynamic")
    allPlayers[name].shape = love.physics.newCircleShape(50)
    allPlayers[name].fixture = love.physics.newFixture(allPlayers[name].body, allPlayers[name].shape)
end

-- client.lua
function love.load()
    love.graphics.setBackgroundColor(1, 1, 1, 1)

    client = sock.newClient("localhost", 8080)

    love.physics.setMeter(64)
    gamestate.world = love.physics.newWorld(0, 9.81*64, true)
    love.graphics.setDefaultFilter("nearest", "nearest")

    menu:load()

    client:on("disconnect", function(data)
        client:on("leaveGame", function(data)
            gamestate.numPlayers = data.numPlayers
        end)
    end)

    --[[client:on("playerData", function(data)
        allPlayers[data.username].x = data.x
        allPlayers[data.username].y = data.y
    end)]]--

    client:connect()

    floor = {}
    floor.body = love.physics.newBody(gamestate.world, love.graphics.getWidth() / 2, love.graphics.getHeight()-100/2, "static")
    floor.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 100)
    floor.fixture = love.physics.newFixture(floor.body, floor.shape)
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
        love.graphics.setColor(1, 0, 0)


        --[[for key, v in pairs(allPlayers) do
            if (allPlayers[key].username ~= menu.input.username) then
                --drawPlayer(allPlayers[key].username, allPlayers[key].x, allPlayers[key].y)
            else
                player:draw()
            end
        end]]--

        player:draw()


        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.polygon("fill", floor.body:getWorldPoints(floor.shape:getPoints()))
    end
end 