local lp = love.physics
local lg = love.graphics

local function _set_funcs(obj1, obj2)  
    for k, v in pairs(obj2.__index) do
        if k~="__gc" and k~="__eq" and k~="__index" and k~="__tostring" and k~="isDestroyed" and k~="testPoint" and k~="getType" and k~="setUserData" and k~="rayCast" and k~="destroy" and k~="getUserData" and k~="release" and k~="type" and k~="typeOf"
        then obj1[k] = function(obj1, ...) return v(obj2, ...) end end
    end
end


local Collider = {}

function Collider:new(world, type, ...)
    local _a, body, shape = {...}
    if     type == "circ"  then body, shape = lp.newBody(world, _a[1], _a[2], _a[4] and _a[4].type or "dynamic"), lp.newCircleShape(_a[3])
    elseif type == "rect"  then body, shape = lp.newBody(world, _a[1], _a[2], _a[5] and _a[5].type or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] and _a[5].angle or 0)
    elseif type == "poly"  then body, shape = lp.newBody(world,     0,     0, _a[2] and _a[2].type or "dynamic"), lp.newPolygonShape(unpack(_a[1]))
    elseif type == "line"  then body, shape = lp.newBody(world,     0,     0, _a[5] and _a[5].type or "dynamic"), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == "chain" then body, shape = lp.newBody(world,     0,     0, _a[3] and _a[3].type or "dynamic"), lp.newChainShape(_a[1], unpack(_a[2])) end

    local obj = {}
        obj.world    = world
        obj.body     = body
        obj.shape    = shape
        obj.fixture  = lp.newFixture(body, shape)
        obj.shapes   = {default = obj.shape}
        obj.fixtures = {default = obj.fixture}
        obj.__index  = Collider
        _set_funcs(obj, obj.body);_set_funcs(obj, obj.shape);_set_funcs(obj, obj.fixture)
    return setmetatable(obj, obj)
end

function Collider:destroy()
    for k, v in pairs(self.fixtures) do v:setUserData(nil); v:destroy(); k[v] = nil end 
    for k, v in pairs(self.shapes) do v:destroy(); k[v] = nil end 
    self.body:setUserData(nil); self.body:destroy(); self.body = nil
end

function Collider:add_shape(type, name, ...)
    local _a, shape = {...}
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

function World:__call(x,y,z) 
    local obj = {}
        obj.box2d_world = lp.newWorld(x,y,z)
        _set_funcs(obj, obj.box2d_world)
    return setmetatable(obj, {__index = World})
end

function World:draw() 
    for k1,v1 in pairs(self:getBodies()) do 
        for k2, v2 in pairs(v1:getFixtures()) do 
            if     v2:getShape():getType() == "circle"  then lg.circle("line", v1:getX(), v1:getY(), v2:getShape():getRadius())
            elseif v2:getShape():getType() == "polygon" then lg.polygon("line", v1:getWorldPoints(v2:getShape():getPoints()))
            else  
                local points = {v1:getWorldPoints(v2:getShape():getPoints())}    
                for i=1, #points, 2 do if i < #points-2 then lg.line(points[i], points[i+1], points[i+2], points[i+3]) end end
            end
        end
    end
end

function World:add_circle(x, y, r, args) return Collider:new(self.box2d_world, "circ", x, y, r, args) end
function World:add_rectangle(x, y, w, h, args) return Collider:new(self.box2d_world, "rect", x, y, w, h, args) end
function World:add_polygon(vertices, args) return Collider:new(self.box2d_world, "poly", vertices, args) end
function World:add_line(x1, y1, x2, y2, args) return Collider:new(self.box2d_world, "line", x1, y1, x2, y2, args) end
function World:add_chain(vertices, loop, args) return Collider:new(self.box2d_world, "chain", vertices, loop, args) end

return setmetatable({}, World)