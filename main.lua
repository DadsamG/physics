lg = love.graphics
require("lib/global_functions")
require("run")


World = require("lib/physics")

local world = World(0, 0)

world:add_chain("walls", true, {1,1, 800,1, 800, 600, 1, 599}, "static")
world:get_collider("walls"):setFriction(1)
world:get_collider("walls").class = "walls"

world:add_circle("ball", 400, 400, 20)
world:get_collider("ball"):setFriction(1)
world:get_collider("ball"):add_rectangle("rect", 0, 0, 10, 100, 0):setSensor(true)
world:get_collider("ball"):setFriction(1)

world:add_rectangle(_, 100, 100, 200, 200)

world:get_shape("ball", "rect"):set_enter(function(c1, s1, c2, s2, contact) if c2.class == "walls" then s1:destroy() end end)
world:get_collider("ball"):set_exit(function(c1, s1, c2, s2, contact) end)
world:get_collider("ball"):set_pre(function(c1, s1, c2, s2, contact) end)
world:get_collider("ball"):set_post(function(c1, s1, c2, s2, contact, ni1, ti1, ni2, ti2) end)

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("up")    then pcall(function() world:get_collider("ball"):applyForce(0, -1000) end) end
    if down("down")  then pcall(function() world:get_collider("ball"):applyForce(0, 1000)  end) end
    if down("right") then pcall(function() world:get_collider("ball"):applyForce(1000, 0)  end) end
    if down("left")  then pcall(function() world:get_collider("ball"):applyForce(-1000, 0) end) end
    if pressed("1")  then pcall(function() world:get_collider("ball"):remove_shape("rect") end) end
    if pressed("2")  then pcall(function() world:remove_collider("ball")                   end) end
    if pressed("3")  then  end
    if pressed("4")  then  end
    if pressed("5")  then  end

    world:update(dt)
end

function love.draw()
   world:draw()
end