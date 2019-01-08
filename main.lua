lg = love.graphics
require("lib/global_functions")
require("run")
World = require("lib/physics")


local world = World()

-- world:setCallbacks(
--     function(a, b, coll) end, -- begin
--     function(a, b, coll) end, -- end 
--     function(a, b, coll) end, -- pre
--     function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
-- )

walls = world:add_chain(true, {1,1, 800,1, 800, 600, 1, 599})
walls:setFriction(0)

ball = world:add_circle(400, 400, 20)
ball:setRestitution(1)
ball:setFriction(0)
ball:add_shape("rectangle",_, 0, 0, 10, 100, 100)

bricks = {ox = 10, oy = 10}
for i = 1, 5 do
    for j = 1, 6 do
        bricks[j] = world:add_rectangle(100 * j + bricks.ox * j-1, 30 * i + bricks.oy * i - 1, 100, 30, {type = "static"})
        bricks[j]:setFriction(0)
    end
end

pad = world:add_rectangle(400, 500, 100, 20)
pad:setRestitution(0)
pad:setLinearDamping(100)
pad:setFriction(0)
pad:setFixedRotation(true)



joint = world:add_joint("prismatic", pad, world:add_rectangle(2,500, 10, 20, {type = "static"}), 400, 500, 1, 0, false )
joint:setLimitsEnabled(false)

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("right") then pad:applyForce( 500000,     500000)  end
    if down("left" ) then pad:applyForce(-500000,     -500000)  end
    if down("space") then ball:applyForce(-5000,     -5000)  end

    world:update(dt)
end

function love.draw()
    world:draw()
end

