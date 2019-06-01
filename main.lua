lg, lp = love.graphics, love.physics
require("global_functions")
require("run")
local Physics = require("physics")

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

local world = Physics(0, 400)
:add_class("Wall")
:add_class("Rect", {"Tri", "Poly"})
:add_class("Tri")
:add_class("Poly")
:add_class("Circ", {"Rect", "Tri", "Poly"})
:add_class("Conc", {"Rect"})

local wall1 = world:add_rectangle(0, 300, 2, 600, _, "static"):set_class("Wall")
local wall2 = world:add_rectangle(800, 300, -2,600, _, "static"):set_class("Wall")
local wall3 = world:add_rectangle(400, 0, 800, 2, _, "static"):set_class("Wall")
local wall4 = world:add_rectangle(400, 600, 800,-2, _, "static"):set_class("Wall")
local rect  = world:add_rectangle(100, 100, 100, 100):set_class("Rect")
local circ  = world:add_circle(200, 210, 50):set_class("Circ")
local tri   = world:add_polygon(200, 200,{0, 0, 0, 100, 100, 0}):set_class("Tri")
local poly  = world:add_polygon(300, 210, {0, 0, 100, 0, 150, 50, 100, 100, 0, 100}):set_class("Poly")
local conc  = world:add_polygon(300, 210, {0, 0, -10, 50, 0, 100, 50, 110, 100, 100, 110, 50, 100, 0, 50, -10}):set_class("Conc")

local joint = world:add_joint("mouse", circ, circ:getX(), circ:getY())


circ:set_enter(function(other, contact)
    if other:get_class() == "Wall" then 
        print(#circ:getContacts())
    end
end)

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    joint:setTarget(love.mouse.getPosition())
    world:update(dt)
end

function love.draw()
    world:draw()
end

-- local sh = lp.newRectangleShape(0, 100, 20, 150, 10)
-- lp.newFixture(circ._body, sh, 1)   

-- circ:set_enter(function(fix1, fix2, contact)
--     local body1, body2, multi_contact = fix1:getBody(), fix2:getBody(), false
--     for k,v in pairs(body1:getContacts()) do for k2,v2 in pairs(body2:getContacts()) do if v == v2 and v ~= contact then multi_contact = true break end end end

--     if not multi_contact then 
--         local class = body2:getUserData():get_class()
--         if class == "Wall" then 
--             print(#circ:getContacts())
--         end
--     end
-- end)