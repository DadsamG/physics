lg = love.graphics
require("lib/global_functions")
require("run")

World = require("lib/physics")


local world = World(0, 100)

-- world:setCallbacks(
--     function(a, b, coll) end, -- begin
--     function(a, b, coll) end, -- end 
--     function(a, b, coll) end, -- pre
--     function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
-- )

local walls = world:add_chain(_, true, {1,1, 800,1, 800, 600, 1, 599}, "static")
walls:setFriction(0)

local ball = world:add_circle(_, 400, 400, 20)
ball:setRestitution(1)
ball:setFriction(0)
ball:add_rectangle("lol", 0, 0, 10, 100, 0)


local bricks = {ox = 10, oy = 10}
for i = 1, 5 do for j = 1, 6 do
    bricks[j] = world:add_rectangle(_, 100 * j + bricks.ox * j-1, 30 * i + bricks.oy * i - 1, 100, 30, _, "static")
    bricks[j]:setFriction(0)
end end

local pad = world:add_rectangle(_, 400, 500, 100, 20, _)
pad:setRestitution(0)
pad:setLinearDamping(100)
pad:setFriction(0)
pad:setFixedRotation(true)


local joint = world:add_joint(_, "prismatic", pad, world:add_rectangle(_, 2,500, 10, 20, _ ,"static" ), 400, 500, 1, 0, false )
joint:setLimitsEnabled(false)

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if pressed("up")   then  end
    if pressed("down") then  end
    if down("right")   then ball:applyForce(1000, 0)  end
    if down("left")    then ball:applyForce(-1000, 0) end
    if pressed("1")    then ball:remove_shape("lol")  end
    if pressed("2")    then ball:destroy()  end
    if pressed("3")    then  end
    if pressed("4")    then  end
    if pressed("5")    then  end

    world:update(dt)
end

function love.draw()
    world:draw()
end

