lg = love.graphics
require("lib/global_functions")
require("run")
--World = require("lib/physics")


-- world = World()

-- world:setCallbacks(
--     function(a, b, coll) end, -- begin
--     function(a, b, coll) end, -- end 
--     function(a, b, coll) end, -- pre
--     function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
-- )


-- ball = world:add_circle(100, 100, 20)
-- ball2 = world:add_circle(200, 100, 20)
-- wall1 = world:add_line(1, 1,  1, 800)


local world = love.physics.newWorld()
    world:setGravity(0, 1000)


world:setCallbacks(
    function(a, b, coll) print(b:getBody():getUserData() .. ", " .. a:getBody():getUserData()) end, -- begin
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
    ball.body = love.physics.newBody(world, 400, 100, "dynamic")
    ball.shape = love.physics.newCircleShape( 20)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(0.9)
    ball.body:setUserData("ball")

local block = {}
    block.body = love.physics.newBody(world, 200, 550, "dynamic")
    block.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    block.fixture = love.physics.newFixture(block.body, block.shape, 1)
    block.body:setUserData("block")


local line = {}
    line.body = love.physics.newBody(world, 200, 550, "dynamic")
    line.shape = love.physics.newChainShape(true,10, 400, 300, 500, 200, 100)
    line.fixture = love.physics.newFixture(line.body, line.shape, 5)
    line.body:setUserData("chain")


print(line.fixture:isSensor())

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("right") then ball.body:applyForce( 1000,     0) end
    if down("left" ) then ball.body:applyForce(-1000,     0) end
    if down("up"   ) then ball.body:applyForce(    0, -1000) end
    if down("down" ) then ball.body:applyForce(    0,  1000) end

    
    world:update(dt)
end

function love.draw()

    lg.setColor(1,1,1)
    lg.line(line.shape:getPoints())

    lg.setColor(0.28, 0.63, 0.05)
    lg.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
    lg.polygon("fill", ground.body:getWorldPoints(ground.shape2:getPoints()))

    lg.setColor(0.76, 0.18, 0.05)
    lg.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())


    lg.setColor(0.1, 0.2, 0.6)
    lg.polygon("fill", block.body:getWorldPoints(block.shape:getPoints()))

    --lg.circle("line", ball:getX(), ball:getY(), ball:getRadius())
    --lg.circle("line", ball2:getX(), ball2:getY(), ball2:getRadius())
    --love.graphics.line(wall1:getPoints( ))

end
