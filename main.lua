lg = love.graphics
require("lib/global_functions")
require("run")
local Physics = require('lib/physics')


local world = Physics(0, 0, true)
world:setGravity(0, 512)
world:setQueryDebugDrawing(true)


ground = world:add_rectangle(0, 550, 800, 50)
wall_left = world:add_rectangle(0, 0, 50, 600)
wall_right = world:add_rectangle(750, 0, 50, 600)
ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
wall_left:setType('static')
wall_right:setType('static')

box_1 = world:add_rectangle(400 - 50/2, 0, 50, 50)
box_1:setRestitution(0.8)
box_2 = world:add_rectangle(400 - 50/2, 50, 50, 50)
box_2:setRestitution(0.8)
box_2:applyAngularImpulse(5000)
joint = world:add_joint('RevoluteJoint', box_1, box_2, 400, 50, true)


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