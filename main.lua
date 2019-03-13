lg = love.graphics
require("lib/global_functions")
require("run")
local Physics = require('lib/physics')


local world = Physics(0, 0, true)
world:add_class("Ball")



local ball = world:add_circle()
ball:set_class("Ball")


-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)

    if pressed("1") then world:query_rectangle(0, 0, 500, 500) end
    world:update(dt)
end

function love.draw()
    world:draw()
end