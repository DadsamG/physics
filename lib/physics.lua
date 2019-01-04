local lp = love.physics
local lg = love.graphics

local function _set_funcs(obj1, obj2)  
    for k, v in pairs(obj2.__index) do
        if k~="__gc" and k~="__eq" and k~="__index" and k~="__tostring" and k~="isDestroyed" and k~="testPoint" and k~="getType" and k~="setUserData" and k~="rayCast" and k~="destroy" and k~="getUserData" and k~="release" and k~="type" and k~="typeOf"
        then obj1[k] = function(obj1, ...) return v(obj2, ...) end end
    end
end

local function uuid()
    local fn = function(x)
        local r = math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789ABCDEF"):sub(r, r)
    end
    return (("xxxxxxxx"):gsub("[x]", fn))
end

local Collider = {}

function Collider:new(world, type, ...)
    local _a, body, shape = {...}
    if     type == "circ"  then body, shape = lp.newBody(world, _a[1], _a[2], _a[4] and _a[4].type or "dynamic"), lp.newCircleShape(_a[3])
    elseif type == "rect"  then body, shape = lp.newBody(world, _a[1], _a[2], _a[5] and _a[5].type or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] and _a[5].angle or 0)
    elseif type == "poly"  then body, shape = lp.newBody(world,     0,     0, _a[2] and _a[2].type or "dynamic"), lp.newPolygonShape(unpack(_a[1]))
    elseif type == "line"  then body, shape = lp.newBody(world,     0,     0, _a[5] and _a[5].type or "static" ), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == "chain" then body, shape = lp.newBody(world,     0,     0, _a[3] and _a[3].type or "static" ), lp.newChainShape(_a[1], unpack(_a[2])) end

    local obj = {}
        obj.world    = world
        obj.body     = body
        obj.shape    = shape
        obj.fixture  = lp.newFixture(body, shape)
        obj.shapes   = {default = obj.shape}
        obj.fixtures = {default = obj.fixture}
        _set_funcs(obj, obj.body);_set_funcs(obj, obj.shape);_set_funcs(obj, obj.fixture)
    return setmetatable(obj, {__index = Collider})
end

function Collider:destroy()
    for k, v in pairs(self.fixtures) do v:setUserData(nil); v:destroy(); k[v] = nil end 
    for k, v in pairs(self.shapes) do v:destroy(); k[v] = nil end 
    self.body:setUserData(nil); self.body:destroy(); self.body = nil
end

function Collider:add_shape(type, name, ...)
    local _a, name, shape = {...}, name or uuid()
    if     type == "circle"    then shape = lp.newCircleShape(_a[1], _a[2], _a[3])
    elseif type == "rectangle" then shape = lp.newRectangleShape(_a[1], _a[2], _a[3], _a[4], _a[5])
    elseif type == "polygon"   then shape = lp.newPolygonShape(unpack(_a[1]))
    elseif type == "line"      then shape = lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == "chain"     then shape = lp.newChainShape(_a[1], unpack(_a[2])) end
    self.fixtures[name], self.shapes[name] = lp.newFixture(self.body, shape), shape
end

-------------------------------
--<<(^__^)  (0___U)  (*__*)>>--
-------------------------------

local World = {}

function World:__call(xg,yg,sleep) 
    local obj = {}
        obj.box2d_world = lp.newWorld(xg,yg,sleep)
        _set_funcs(obj, obj.box2d_world)
    return setmetatable(obj, {__index = World})
end

function World:draw() 
    -- Joints --
    -- Colliders --
    for k1,v1 in pairs(self:getBodies()) do for k2, v2 in pairs(v1:getFixtures()) do 
        if     v2:getShape():getType() == "circle"  then lg.circle("line", v1:getX(), v1:getY(), v2:getShape():getRadius())
        elseif v2:getShape():getType() == "polygon" then lg.polygon("line", v1:getWorldPoints(v2:getShape():getPoints()))
        else   local _p = {v1:getWorldPoints(v2:getShape():getPoints())}; for i=1, #_p, 2 do if i < #_p-2 then lg.line(_p[i], _p[i+1], _p[i+2], _p[i+3]) end end end
    end end
end

function World:add_circle(x, y, r, args) return Collider:new(self.box2d_world, "circ", x, y, r, args) end
function World:add_rectangle(x, y, w, h, args) return Collider:new(self.box2d_world, "rect", x, y, w, h, args) end
function World:add_polygon(vertices, args) return Collider:new(self.box2d_world, "poly", vertices, args) end
function World:add_line(x1, y1, x2, y2, args) return Collider:new(self.box2d_world, "line", x1, y1, x2, y2, args) end
function World:add_chain(vertices, loop, args) return Collider:new(self.box2d_world, "chain", vertices, loop, args) end

function World:add_joint(type, col1, col2, ...)
    if     type == "distance"  then return lp.newDistanceJoint(col1.body, col2.body, ...)
    elseif type == "friction"  then return lp.newFrictionJoint(col1.body, col2.body, ...)
    elseif type == "gear"      then return lp.newGearJoint(col1.body, col2.body, ...)
    elseif type == "motor"     then return lp.newMotorJoint(col1, col2, ...)
    elseif type == "mouse"     then return lp.newMouseJoint(col1.body, col2.body, ...)
    elseif type == "prismatic" then return lp.newPrismaticJoint(col1.body, col2.body, ...)
    elseif type == "pulley"    then return lp.newPulleyJoint(col1.body, col2.body, ...)
    elseif type == "revolute"  then return lp.newRevoluteJoint(col1.body, col2.body, ...)
    elseif type == "rope"      then return lp.newRopeJoint(col1.body, col2.body, ...)
    elseif type == "weld"      then return lp.newWeldJoint(col1.body, col2.body, ...)
    elseif type == "wheel"     then return lp.newWheelJoint(col1.body, col2.body, ...) end
end

return setmetatable({}, World)