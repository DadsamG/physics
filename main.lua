lg = love.graphics
require("lib/global_functions")
require("run")

Textbox = require("lib/textbox")
World = require("lib/physics")


local world = World(0, 0)


world:add_chain("walls", true, {1,1, 800,1, 800, 600, 1, 599}, "static")
world:get_c("walls"):setFriction(0)


world:add_circle("ball", 400, 400, 20)
world:get_c("ball"):setRestitution(1)
world:get_c("ball"):setFriction(0)
world:get_c("ball"):add_rectangle("rect", 0, 0, 10, 100, 0)

world:get_s("ball", "rect"):set_exit(function(collider1, shape1, collider2, shape2) print("lol") end)

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

