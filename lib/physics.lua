local lp = love.physics

local function _set_funcs(obj1, obj2)
    for k, v in pairs(obj2.__index) do
        if k~='__gc' and k~='__eq' and k~='__index' and k~='__tostring' and k~='destroy' and k~='type' and k~='typeOf' and k~='release' and k~='getType' and k~='rayCast' and k~='testPoint' and k~='getUserData' and k~='setUserData' and k~='isDestroyed' 
        then obj1[k] = function(obj1, ...) return v(obj2, ...) end end
    end
end

local function _new_collider(world, type, ...)
    local _a, body, shape = {...}
    if     type == 'circle' then body, shape = lp.newBody(world, _a[1], _a[2], (pcall(function() return _a[4].type end) or "dynamic")), lp.newCircleShape(_a[3])
    elseif type == 'rect'   then body, shape = lp.newBody(world, _a[1], _a[2], (pcall(function() return _a[5].type end) or "dynamic")), lp.newRectangleShape(_a[3], _a[4])
    elseif type == 'poly'   then body, shape = lp.newBody(world, 0, 0, (pcall(function() return _a[2].type end) or "dynamic")), lp.newPolygonShape(unpack(_a[1]))
    elseif type == 'line'   then body, shape = lp.newBody(world, 0, 0, (pcall(function() return _a[5].type end) or "dynamic")), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == 'chain'  then body, shape = lp.newBody(world, 0, 0, (pcall(function() return _a[3].type end) or "dynamic")), lp.newChainShape(_a[1], unpack(_a[2])) end


    local obj = {}
        obj.world   = world
        obj.body    = body
        obj.shape   = shape
        obj.fixture = love.physics.newFixture(body, shape)
        -- obj.fixture:setUserData(self)
        obj.shapes   = {default = shape}
        obj.fixtures = {default = fixture}

        _set_funcs(obj, obj.body)
        _set_funcs(obj, obj.shape)
        _set_funcs(obj, obj.fixture)
    return obj
end   

local Collider = {}

function Collider:add_shape(shape) end
function Collider:destroy() end




local World = {}



function World:__call(x,y,z) 
    local obj = {}
        obj.box2d_world = lp.newWorld(x,y,z)
        _set_funcs(obj, obj.box2d_world)


    return setmetatable(obj, {__index = World})
end

function World:add_circle(x, y, r, settings) return _new_collider(self.box2d_world, 'circle', x, y, r, settings) end
function World:add_rectangle(x, y, w, h, settings)  return _new_collider(self.box2d_world, 'rect', x, y, w, h, settings) end
function World:add_polygon(vertices, settings) return _new_collider(self.box2d_world, 'poly', vertices, settings) end
function World:add_line(x1, y1, x2, y2, settings) return _new_collider(self.box2d_world, 'line', x1, y1, x2, y2, settings) end
function World:add_chain(vertices, loop, settings) return _new_collider(self.box2d_world, 'chain', vertices, loop, settings) end




return setmetatable({}, World)