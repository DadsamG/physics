lg = love.graphics
require("lib/global_functions")


local world = love.physics.newWorld()
world:setGravity(0, 1000)
world:setCallbacks(
    function(a, b, coll) print(a:getBody():getUserData()) end, -- begin
    function(a, b, coll) end, -- end 
    function(a, b, coll) end, -- pre
    function(a, b, coll, normalimpulse, tangentimpulse) end -- post
)


local ground = {}
ground.body = love.physics.newBody(world, lg.getWidth()/2, lg.getHeight()) 
ground.shape = love.physics.newRectangleShape(800, 20)
ground.shape2 = love.physics.newRectangleShape(200, 0,20, 100, 20)
ground.fixture = love.physics.newFixture(ground.body, ground.shape)
ground.fixture2 = love.physics.newFixture(ground.body, ground.shape2)
ground.body:setUserData("ground")

local ball = {}
ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
ball.shape = love.physics.newCircleShape( 20)
ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
ball.fixture:setRestitution(0.9)
ball.body:setUserData("ball")

local block = {}
block.body = love.physics.newBody(world, 200, 550, "dynamic")
block.shape = love.physics.newRectangleShape(0, 0, 50, 100)
block.fixture = love.physics.newFixture(block.body, block.shape, 5)


function love.update(dt)
    world:update(dt)

    if down("right") then ball.body:applyForce( 1000, 0) end
    if down("left" ) then ball.body:applyForce(-1000, 0) end
    if down("up"   ) then ball.body:setPosition(650/2, 650/2); ball.body:setLinearVelocity(0, 0) end 
end

function love.draw()

    lg.setColor(0.28, 0.63, 0.05)
    lg.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
    lg.polygon("fill", ground.body:getWorldPoints(ground.shape2:getPoints()))

    lg.setColor(0.76, 0.18, 0.05)
    lg.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    
    lg.setColor(0.20, 0.20, 0.20)
    lg.polygon("fill", block.body:getWorldPoints(block.shape:getPoints()))

end











-------------------------------
-------------------------------
-------------------------------

function love.run()
    local dt = 0
    local _INPUT = {current_state = {}, previous_state = {}}
    lg.setLineStyle("rough")
    lg.setDefaultFilter("nearest", "nearest")

    function pressed(key) return _INPUT.current_state[key] and not _INPUT.previous_state[key] end
    function released(key) return _INPUT.previous_state[key] and not _INPUT.current_state[key] end
    function down(key) return love.keyboard.isDown(key) end   

	return function()
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit"        then if not love.quit or not love.quit() then return a or 0 end end
            if name == "keypressed"  then _INPUT.current_state[a] = true  end
            if name == "keyreleased" then _INPUT.current_state[a] = false end
            love.handlers[name](a,b,c,d,e,f)
        end
		
        dt = love.timer.step()
        if dt > 0.2 then return end
        love.update(dt)
        for k,v in pairs(_INPUT.current_state) do _INPUT.previous_state[k] = v end 
        
		if lg.isActive() then lg.origin(); lg.clear(lg.getBackgroundColor()); love.draw(); lg.present() end
		love.timer.sleep(0.001)
	end
end