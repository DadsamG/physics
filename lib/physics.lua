local lp = love.physics

local function _set_funcs(obj1, obj2)
    for k, v in pairs(obj2.__index) do
        if k~='__gc' and k~='__eq' and k~='__index' and k~='__tostring' and k~='destroy' and k~='type' and k~='typeOf' and k~='release' and k~='getType' and k~='rayCast' and k~='testPoint' and k~='getUserData' and k~='setUserData' and k~='isDestroyed' 
        then obj1[k] = function(obj1, ...) return v(obj2, ...) end end
    end
end

local function _new_collider(world, type, ...)
    local _a, body, shape = {...}
    if     type == 'circle'    then body, shape = lp.newBody(world,_a[1],_a[2],(_a[4] and _a[4].body_type) or 'dynamic'), lp.newCircleShape(_a[3])
    elseif type == 'rectangle' then body, shape = lp.newBody(world,_a[1]+_a[3]/2,_a[2]+_a[4]/2,(_a[5] and _a[5].body_type) or 'dynamic'), lp.newRectangleShape(_a[3], _a[4])
    elseif type == 'polygon'   then body, shape = lp.newBody(world, 0, 0, (_a[2] and _a[2].body_type) or 'dynamic'), lp.newPolygonShape(unpack(_a[1]))
    elseif type == 'line'      then body, shape = lp.newBody(world, 0, 0, (_a[5] and _a[5].body_type) or 'dynamic'), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif type == 'chain'     then body, shape = lp.newBody(world, 0, 0, (_a[3] and _a[3].body_type) or 'dynamic'), lp.newChainShape(_a[1], unpack(_a[2])) end

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

local World = {}

function World:add_circle(x, y, r, settings) return _new_collider(self, 'circle', x, y, r, settings) end
function World:add_rectangle(x, y, w, h, settings) return _new_collider(self, 'rectangle', x, y, w, h, settings) end
function World:add_polygon(vertices, settings) return _new_collider(self, 'polygon', vertices, settings) end
function World:add_line(x1, y1, x2, y2, settings) return _new_collider(self, 'line', x1, y1, x2, y2, settings) end
function World:add_chain(vertices, loop, settings) return _new_collider(self, 'chain', vertices, loop, settings) end


local Collider = {}

function Collider:add_shape(shape) end
function Collider:destroy() end