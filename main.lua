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


rect = world:add_rectangle(400, 400, 100, 200)

line = world:add_line(50, 50, 500, 10)
line:setRestitution(1)

chain = world:add_chain(false,{50, 50, 100, 100, 100, 160})
chain:setRestitution(1)

poly = world:add_polygon({200,200, 200, -30, -30,300, 300,300, 300,200})

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function love.update(dt)
    if down("right") then ball.body:applyForce( 1000,     0) end
    if down("left" ) then ball.body:applyForce(-1000,     0) end
    if down("up"   ) then ball.body:applyForce(    0, -1000) end
    if down("down" ) then ball.body:applyForce(    0,  1000) end

    
    world:update(dt)
end

function love.draw()

    lg.circle("line", ball:getX(), ball:getY(), ball:getRadius())
    lg.circle("line", ball2:getX(), ball2:getY(), ball2:getRadius())
    lg.circle("line", ball3:getX(), ball3:getY(), ball3:getRadius())
    lg.circle("line", ball4:getX(), ball4:getY(), ball4:getRadius())
    lg.circle("line", ball5:getX(), ball5:getY(), ball5:getRadius())
    lg.circle("line", ball6:getX(), ball6:getY(), ball6:getRadius())


    lg.polygon("line", wall1:getWorldPoints(wall1:getPoints()))
    lg.polygon("line", wall2:getWorldPoints(wall2:getPoints()))
    lg.polygon("line", wall3:getWorldPoints(wall3:getPoints()))
    lg.polygon("line", wall4:getWorldPoints(wall4:getPoints()))

    lg.line(line:getWorldPoints(line:getPoints()))

    local points = {chain:getWorldPoints(chain:getShape():getPoints())}    
    for i = 1, #points, 2 do
        if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
    end

    lg.polygon("line", rect:getWorldPoints(rect:getPoints()))
    lg.polygon("line", poly:getWorldPoints(poly:getPoints()))

end

