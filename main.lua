lg = love.graphics
require("lib/global_functions")
require("run")
World = require("lib/physics")


world = World()

-- world:setCallbacks(
--     function(a, b, coll) end, -- begin
--     function(a, b, coll) end, -- end 
--     function(a, b, coll) end, -- pre
--     function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
-- )


ball = world:add_circle(500, 500, 20)
ball:setRestitution(1)
ball2 = world:add_circle(200, 100, 20)
ball3 = world:add_circle(300, 100, 20)
ball4 = world:add_circle(400, 100, 20)
ball5 = world:add_circle(500, 100, 20)
ball6 = world:add_circle(600, 100, 20)

wall1 = world:add_rectangle(400,   1, 800,   1, {type = "static"})
wall2 = world:add_rectangle(400, 599, 800,   1, {type = "static"})
wall3 = world:add_rectangle(1,   300,   1, 600, {type = "static"})
wall4 = world:add_rectangle(799, 300,   1, 600, {type = "static"})

rect  = world:add_rectangle(400, 400, 100, 200, {angle = 1})
rect:add_shape("circle", "test", 0, 0, 100)

line  = world:add_line(50, 50, 500, 10)
line:setRestitution(1)

chain = world:add_chain(false,{50, 50, 100, 100, 100, 160})
chain:setRestitution(1)

poly  = world:add_polygon({200,200, 200, -30, -30,300, 300,300, 300,200})
poly:add_shape("rectangle", "test", 100, 100, 100, 200, 40)
poly:add_shape("circle", "test2", 0, 0, 100)


-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("right") then ball:applyForce( 1000,     0) end
    if down("left" ) then ball:applyForce(-1000,     0) end
    if down("up"   ) then ball:applyForce(    0, -1000) end
    if down("down" ) then ball:applyForce(    0,  1000) end

    
    world:update(dt)
end

function love.draw()
    world:draw()
end

