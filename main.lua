lg = love.graphics
require("lib/global_functions")
require("run")

Textbox = require("lib/textbox")
World = require("lib/physics")


local world = World(0, 0)

-- world:setCallbacks(
--     function(a, b, coll) end, -- begin
--     function(a, b, coll) end, -- end 
--     function(a, b, coll) end, -- pre
--     function(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2, ...) end -- post
-- )

-- ball:on_enter(function() dostuff end)
-- ball:on_exit(function() dostuff end)
-- ball:presolve(function() dostuff end)
-- ball:postsolve(function() dostuff end)




world:add_chain("walls", true, {1,1, 800,1, 800, 600, 1, 599}, "static")
world:get_c("walls"):setFriction(0)

print(world:is_collider("walls"))

world:add_circle("ball", 400, 400, 20)
world:get_c("ball"):setRestitution(1)
world:get_c("ball"):setFriction(0)
world:get_c("ball"):add_rectangle("lol", 0, 0, 10, 100, 0)


-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("up")    then world:get_c("ball"):applyForce(0, -1000) end
    if down("down")  then world:get_c("ball"):applyForce(0, 1000)  end
    if down("right") then world:get_c("ball"):applyForce(1000, 0)  end
    if down("left")  then world:get_c("ball"):applyForce(-1000, 0) end
    if pressed("1")  then world:get_c("ball"):remove_shape("lol")  end
    if pressed("2")  then world:get_c("ball"):destroy()            end
    if pressed("3")  then  end
    if pressed("4")  then  end
    if pressed("5")  then  end

    world:update(dt)
end

function love.draw()
   world:draw()
    Textbox:draw(100, 10)
end

