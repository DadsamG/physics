local lp, lg = love.physics, love.graphics

local function _set_funcs(obj1, obj2)  
    for k, v in pairs(obj2.__index) do
        if k~="__gc" and k~="__eq" and k~="__index" and k~="__tostring" and k~="isDestroyed" and k~="testPoint" and k~="getType" and k~="setUserData" and k~="rayCast" and k~="destroy" and k~="getUserData" and k~="release" and k~="type" and k~="typeOf" then obj1[k] = function(obj1, ...) return v(obj2, ...) end end
    end
end

local function _uuid()
    local fn = function(x) local r = math.random(16) - 1; r=(x=="x")and(r+1)or(r%4)+9; return ("0123456789ABCDEF"):sub(r, r) end
    return (("xxxxxxxx"):gsub("[x]", fn))
end

-------------------------------
--<<(^__^)  (0___U)  (*__*)>>--
-------------------------------

local Collider = {}

function Collider:new(world, collider_type, ...)
    local _w, _t, _a, _b, _s = world, collider_type, {...}
    if     _t == "circ"  then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[4] and _a[4].type or "dynamic"), lp.newCircleShape(_a[3])
    elseif _t == "rect"  then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[5] and _a[5].type or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] and _a[5].angle or 0)
    elseif _t == "poly"  then _b, _s = lp.newBody(_w,     0,     0, _a[2] and _a[2].type or "dynamic"), lp.newPolygonShape(unpack(_a[1]))
    elseif _t == "line"  then _b, _s = lp.newBody(_w,     0,     0, _a[5] and _a[5].type or "static" ), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _t == "chain" then _b, _s = lp.newBody(_w,     0,     0, _a[3] and _a[3].type or "static" ), lp.newChainShape(_a[1], unpack(_a[2])) end

    local obj = {}
        obj.world    = _w
        obj.body     = _b
        obj.shape    = _s
        obj.fixture  = lp.newFixture(_b, _s)
        obj.shapes   = {default = obj.shape}
        obj.fixtures = {default = obj.fixture}
        _set_funcs(obj, obj.body)
        _set_funcs(obj, obj.shape)
        _set_funcs(obj, obj.fixture)
    return setmetatable(obj, {__index = Collider})
end

function Collider:destroy()
    for k, v in pairs(self.fixtures) do v:setUserData(nil); v:destroy(); k[v] = nil end 
    for k, v in pairs(self.shapes) do v:destroy(); k[v] = nil end 
    self.body:setUserData(nil); self.body:destroy(); self.body = nil
end

function Collider:add_shape(type, name, ...)
    local _n, _a, _s = name or _uuid(), {...}
    if     type == "circle"    then _s = lp.newCircleShape(_a[1], _a[2], _a[3])
    elseif type == "rectangle" then _s = lp.newRectangleShape(_a[1], _a[2], _a[3], _a[4], _a[5])
    elseif type == "polygon"   then _s = lp.newPolygonShape(unpack(_a[1]))
    elseif type == "line"      then _s = lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == "chain"     then _s = lp.newChainShape(_a[1], unpack(_a[2])) end
    self.fixtures[_n],self.shapes[_n] = lp.newFixture(self.body, _s), _s
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
    -- Colliders --
    for k1,v1 in pairs(self:getBodies()) do for k2, v2 in pairs(v1:getFixtures()) do 
        if     v2:getShape():getType() == "circle"  then lg.circle("line", v1:getX(), v1:getY(), v2:getShape():getRadius())
        elseif v2:getShape():getType() == "polygon" then lg.polygon("line", v1:getWorldPoints(v2:getShape():getPoints()))
        else   local _p = {v1:getWorldPoints(v2:getShape():getPoints())}; for i=1, #_p, 2 do if i < #_p-2 then lg.line(_p[i], _p[i+1], _p[i+2], _p[i+3]) end end end
    end end

    -- Joints --
    love.graphics.setColor(1, 0.5, 0.25)
    for _, joint in ipairs(self.box2d_world:getJoints()) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then love.graphics.circle('line', x1, y1, 6) end
        if x2 and y2 then love.graphics.circle('line', x2, y2, 6) end
    end
    love.graphics.setColor(1, 1, 1)
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