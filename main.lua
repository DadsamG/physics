lg = love.graphics
require("lib/global_functions")
require("run")


World = require("lib/physics")

local world = World(0, 0)
world:add_class("bull")
:set_enter(function() print("class bull enter") end)
:set_exit(function() print("class bull exit") end)


local ball = world:add_circle("ball", 400, 400, 20)

ball:set_enter(function() print("coll bal+r enter") end)
ball:set_exit(function() print("coll bal+r exit") end)
ball:set_pre(function() print("coll bal+r pre") end)
ball:set_class("bull")

local sh_rect = ball:add_rectangle("rect", 0, 0, 10, 300)
sh_rect:set_enter(function() print("shape rect enter") end)
sh_rect:set_exit(function() print("shape rect exit") end)
sh_rect:setSensor(true)


local walls = world:add_chain("walls", true, {1,1, 800,1, 800, 600, 1, 599}, "static")

local bg = world:add_rectangle("bg", 150, 200, 200, 200)
bg:setMass(10000)
bg:setInertia(0)



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