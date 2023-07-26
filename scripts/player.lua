local player = {
	x = love.graphics.getWidth() / 2,
	y = 100,
	username = nil,
	physics = {
		body = nil,
		shape = nil,
		fixture = nil
	}
}

t = 0

function player:init(username, world)
	local nametagFont = love.graphics.newFont(30)
	love.graphics.setFont(nametagFont)

	self.username = username

	self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.physics.shape = love.physics.newCircleShape(50)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function player:update(client, dt)
	local velX, velY = self.physics.body:getLinearVelocity()

    t = t + dt
    if t >= 0.016 then
    	t = 0
    	client:send("playerPosition", {
			username = self.username,
			x = self.physics.body:getX(),
			y = self.physics.body:getY(),
		})
    end
end

function player:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(self.username, self.physics.body:getX() - 250, self.physics.body:getY() - 75*1.5, 500, "center")

	love.graphics.setColor(0.28, 0.63, 0.05)
  	love.graphics.circle("fill", self.physics.body:getX(), self.physics.body:getY(), self.physics.shape:getRadius())
end

return player