local sti = require "lib/sti"
local gamestate = require "scripts/gamestate"

local map = {
	scale = 7
}

function map:load()
 	_map = sti("maps/map.lua")
    
    self.width = (_map.width * _map.tilewidth) * self.scale
    self.height = (_map.height * _map.tileheight) * self.scale

    local solids = {}
	if (_map.layers["Solids"]) then
		for i, obj in pairs(_map.layers["Solids"].objects) do
			solids.body = love.physics.newBody(gamestate.world, (obj.x+obj.width/2)*self.scale, (obj.y+obj.height/2)*self.scale, "static")
			solids.shape = love.physics.newRectangleShape(obj.width*self.scale, obj.height*self.scale)
			solids.fixture = love.physics.newFixture(solids.body, solids.shape)
			solids.fixture:setUserData("Solids")
		end
	end	
end

function map:draw()
	love.graphics.push()
	love.graphics.scale(map.scale)
	_map:drawImageLayer("Map")
	love.graphics.pop()
end

return map