lg = love.graphics
require("lib/global_functions")
require("run")


local world = love.physics.newWorld()
world:setGravity(0, 1000)
world:setCallbacks(
    function(a, b, coll) print(a:getBody():getUserData()) end, -- begin
    function(a, b, coll) end, -- end 
    function(a, b, coll) end, -- pre
    function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
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
