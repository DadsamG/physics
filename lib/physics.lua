local World, Collider, Shape, lp, lg = {}, {}, {}, love.physics, love.graphics

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

local function _set_funcs(obj1, obj2) for k, v in pairs(obj2.__index) do if
    k~="__gc"        and 
    k~="__eq"        and 
    k~="__index"     and 
    k~="__tostring"  and 
    k~="isDestroyed" and 
    k~="testPoint"   and 
    k~="getType"     and
    k~="rayCast"     and 
    k~="destroy"     and 
    k~="setUserData" and
    k~="getUserData" and
    k~="release"     and 
    k~="type"        and 
    k~="typeOf" 
    then obj1[k] = function(obj1, ...) return v(obj2, ...) end end end 
end
local function _uuid() local fn = function(x) local r = math.random(16) - 1; r=(x=="x")and(r+1)or(r%4)+9; return ("0123456789ABCDEF"):sub(r, r) end; return (("xxxxxxxx"):gsub("[x]", fn)) end
local function _run_col(fix1, fix2, coll_type, ...)
    local body1, body2   = fix1:getBody()     , fix2:getBody()
    local coll1, coll2   = body1:getUserData(), body2:getUserData()
    local shape1, shape2 = fix1:getUserData() , fix2:getUserData()
    shape1[coll_type](coll2, shape2, coll1, shape1, ...)
    shape2[coll_type](coll1, shape1, coll2, shape2, ...)
    coll1[coll_type](coll2, shape2, coll1, shape1, ...)
    coll2[coll_type](coll1, shape1, coll2, shape2, ...)
end
local function _enter(a,b)      return _run_col(a, b, '_enter'    ) end
local function _exit(a, b)      return _run_col(a, b, '_exit'     ) end
local function _pre(a, b)       return _run_col(a, b, '_pre'      ) end
local function _post(a, b, ...) return _run_col(a, b, '_post', ...) end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:__call(xg,yg,sleep)
    local obj = {}
        obj.box2d_world = lp.newWorld(xg,yg,sleep)
        obj.box2d_world:setCallbacks(_enter, _exit, _pre, _post)
        obj.colliders   = {}
        obj.joints      = {}
        _set_funcs(obj, obj.box2d_world)
    return setmetatable(obj, {__index = World})
end

function World:draw()
    -- Colliders --
    local _r, _g, _b, _a = lg.getColor()
    lg.setColor(1, 1, 1)
    for k1,v1 in pairs(self:getBodies()) do for k2, v2 in pairs(v1:getFixtures()) do 
        if     v2:getShape():getType() == "circle"  then lg.circle("line", v1:getX(), v1:getY(), v2:getShape():getRadius())
        elseif v2:getShape():getType() == "polygon" then lg.polygon("line", v1:getWorldPoints(v2:getShape():getPoints()))
        else   local _p = {v1:getWorldPoints(v2:getShape():getPoints())}; for i=1, #_p, 2 do if i < #_p-2 then lg.line(_p[i], _p[i+1], _p[i+2], _p[i+3]) end end end
    end end
    -- Joints --
    lg.setColor(1, 0.5, 0.25)
    for _, joint in ipairs(self.box2d_world:getJoints()) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then lg.circle('line', x1, y1, 6) end
        if x2 and y2 then lg.circle('line', x2, y2, 6) end
    end
    lg.setColor(_r, _g, _b, _a)
end

function World:add_collider(tag, collider_type, ...)
    local _w, _tag, _ct, _a, _b, _s, _collider = self.box2d_world, tag or uuid(), collider_type, {...}, nil, nil, setmetatable({}, {__index = Collider})
    if self.colliders[_tag] then print("Collider called " .. _tag .. " already exist.") while self.colliders[_tag] do _tag = uuid() end end
    if     _ct == "circle"    then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[4] or "dynamic"), lp.newCircleShape(_a[3])
    elseif _ct == "rectangle" then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[6] or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] or 0)
    elseif _ct == "polygon"   then _b, _s = lp.newBody(_w,     0,     0, _a[2] or "dynamic"), lp.newPolygonShape(unpack(_a[1]))
    elseif _ct == "line"      then _b, _s = lp.newBody(_w,     0,     0, _a[5] or "static" ), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _ct == "chain"     then _b, _s = lp.newBody(_w,     0,     0, _a[3] or "static" ), lp.newChainShape(_a[1], unpack(_a[2]))  end
    _collider.world  = self
    _collider.tag    = _tag
    _collider.body   = _b
    _collider.shapes = {}
    _collider.shapes["main"] = setmetatable({   
        tag     = "main", 
        shape   = _s, 
        fixture = lp.newFixture(_b, _s, 1),
        _enter  = function() end,
        _exit   = function() end,
        _pre    = function() end,
        _post   = function() end  
    }, {__index = Shape})
    _collider._enter = function() end 
    _collider._exit  = function() end
    _collider._pre   = function() end 
    _collider._post  = function() end 
    _set_funcs(_collider, _collider.body)
    _set_funcs(_collider, _collider.shapes["main"].shape)
    _set_funcs(_collider, _collider.shapes["main"].fixture)
    _set_funcs(_collider.shapes["main"], _collider.shapes["main"].shape)
    _set_funcs(_collider.shapes["main"], _collider.shapes["main"].fixture)
    _collider.body:setUserData(_collider)
    _collider.shapes["main"].fixture:setUserData(_collider.shapes["main"])
    self.colliders[_tag] = _collider 
    return _collider
end

function World:add_circle(tag, x, y, r, move_type)          return self:add_collider(tag, "circle"   , x, y, r, move_type)        end
function World:add_rectangle(tag, x, y, w, h, r, move_type) return self:add_collider(tag, "rectangle", x, y, w, h, r, move_type)  end
function World:add_polygon(tag, vertices, move_type)        return self:add_collider(tag, "polygon"  , vertices, move_type)       end
function World:add_line(tag, x1, y1, x2, y2, move_type)     return self:add_collider(tag, "line"     , x1, y1, x2, y2, move_type) end
function World:add_chain(tag, loop, vertices, move_type)    return self:add_collider(tag, "chain"    , loop, vertices, move_type) end

function World:get_collider(tag)              return self.colliders[tag]                        end
function World:get_c(tag)                     return self.colliders[tag]                        end
function World:get_shape(coll_tag, shape_tag) return self.colliders[coll_tag].shapes[shape_tag] end
function World:get_s(coll_tag, shape_tag)     return self.colliders[coll_tag].shapes[shape_tag] end
function World:is_collider(tag)               return self.colliders[tag] ~= nil                 end

function World:remove_collider(tag) if not self.colliders[tag] then print("Collider: " .. tag .. " doesn't exist.") else self.colliders[tag]:destroy() end return self end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_joint(tag, joint_type, col1, col2, ...)
    local _tag, _jt, _joint = tag or _uuid(), joint_type, nil
    if self.joints[_tag] then print("Joint: " .. _tag .. " already exist.") while self.joints[_tag] do _tag = uuid() end end
    if     _jt == "distance"  then _joint = lp.newDistanceJoint(col1.body, col2.body, ...)
    elseif _jt == "friction"  then _joint = lp.newFrictionJoint(col1.body, col2.body, ...)
    elseif _jt == "gear"      then _joint = lp.newGearJoint(col1.body, col2.body, ...)    
    elseif _jt == "motor"     then _joint = lp.newMotorJoint(col1, col2, ...)             
    elseif _jt == "mouse"     then _joint = lp.newMouseJoint(col1.body, col2.body, ...)   
    elseif _jt == "prismatic" then _joint = lp.newPrismaticJoint(col1.body, col2.body, ...)
    elseif _jt == "pulley"    then _joint = lp.newPulleyJoint(col1.body, col2.body, ...)  
    elseif _jt == "revolute"  then _joint = lp.newRevoluteJoint(col1.body, col2.body, ...)
    elseif _jt == "rope"      then _joint = lp.newRopeJoint(col1.body, col2.body, ...)    
    elseif _jt == "weld"      then _joint = lp.newWeldJoint(col1.body, col2.body, ...)    
    elseif _jt == "wheel"     then _joint = lp.newWheelJoint(col1.body, col2.body, ...) end
    self.joints[_tag] = _joint 
    return _joint 
end

function World:get_joint(tag) return self.joints[tag]        end
function World:get_j(tag)     return self.joints[tag]        end
function World:is_joint(tag)  return self.joints[tag] ~= nil end

function World:remove_joint(tag)
    if not self.joints[tag] then print("Joint: " .. tag .. " doesn't exist.") return end
    self.joints[tag]:setUserData(nil)
    self.joints[tag]:destroy()
    self.joints[tag] = nil
    return self
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Collider:add_shape(tag, shape_type, ...)
    local _tag, _st,  _a, _shape = tag or _uuid(), shape_type, {...}, nil
    if self.shapes[_tag] then print("Shape: " .. _tag .. " already exist.") while self.shapes[_tag] do _tag = uuid() end end
    if     _st == "circle"    then _shape = lp.newCircleShape(_a[1], _a[2], _a[3])
    elseif _st == "rectangle" then _shape = lp.newRectangleShape(_a[1], _a[2], _a[3], _a[4], _a[5])
    elseif _st == "polygon"   then _shape = lp.newPolygonShape(unpack(_a[1]))
    elseif _st == "line"      then _shape = lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _st == "chain"     then _shape = lp.newChainShape(_a[1], unpack(_a[2])) end
    self.shapes[_tag] = setmetatable({   
        tag     = _tag, 
        collider = self
        shape   = _shape, 
        fixture = lp.newFixture(self.body, _shape, 1),
        _enter  = function() end,
        _exit   = function() end,
        _pre    = function() end,
        _post   = function() end  
    }, {__index = Shape})

    _set_funcs(self.shapes[_tag], self.shapes[_tag].shape)
    _set_funcs(self.shapes[_tag], self.shapes[_tag].fixture)
    self.shapes[_tag].fixture:setUserData(self.shapes[_tag])
    return self.shapes[_tag]
end

function Collider:add_circle(tag, x, y, r)       return self:add_shape(tag, "circle"   , x, y, r)        end
function Collider:add_rectangle(tag, x, y, w, h) return self:add_shape(tag, "rectangle", x, y, w, h)     end
function Collider:add_polygon(tag, vertices)     return self:add_shape(tag, "polygon"  , vertices)       end
function Collider:add_line(tag, x1, y1, x2, y2)  return self:add_shape(tag, "line"     , x1, y1, x2, y2) end
function Collider:add_chain(tag, loop, vertices) return self:add_shape(tag, "chain"    , loop, vertices) end

function Collider:get_shape(tag) return self.shapes[tag]        end
function Collider:get_s(tag)     return self.shapes[tag]        end
function Collider:is_shape(tag)  return self.shapes[tag] ~= nil end

function Collider:remove_shape(tag) if not self.shapes[tag] then print("Shape: " .. tag .. " doesn't exist.") else self.colliders[tag]:destroy() end return self end

function Collider:set_enter(func) if type(func) ~= "function" then print("set_enter is not a function.") else self._enter = func end return self end
function Collider:set_exit(func)  if type(func) ~= "function" then print("set_exit is not a function.")  else self._exit  = func end return self end
function Collider:set_pre(func)   if type(func) ~= "function" then print("set_pre is not a function.")   else self._pre   = func end return self end
function Collider:set_post(func)  if type(func) ~= "function" then print("set_post is not a function.")  else self._post  = func end return self end

function Collider:destroy()
    if self.body:isDestroyed() then print("Collider: " .. self.tag .. " already destroyed.") return end
    for k,v in pairs(self.shapes) do v.fixture:setUserData(nil); v.fixture:destroy() end
    self.body:setUserData(nil); self.body:destroy()
    self.shapes = {}
    self._enter, self._exit, self._pre, self._post = function() end, function() end, function() end, function() end
    self.world.colliders[self.tag] = nil
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Shape:set_enter(func) if type(func) ~= "function" then print("set_enter is not a function.") else self._enter = func end return self end
function Shape:set_exit(func)  if type(func) ~= "function" then print("set_exit is not a function.")  else self._exit  = func end return self end
function Shape:set_pre(func)   if type(func) ~= "function" then print("set_pre is not a function.")   else self._pre   = func end return self end
function Shape:set_post(func)  if type(func) ~= "function" then print("set_post is not a function.")  else self._post  = func end return self end

function Shape:destroy()
    if self.fixture:isDestroyed() then print("Shape: " .. self.tag .. " already destroyed.") return end 
    self.fixture:setUserData(nil); self.fixture:destroy()
    self._enter, self._exit, self._pre, self._post = function() end, function() end, function() end, function() end
    self.collider.shapes[self.tag] = nil
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

return setmetatable({}, World)