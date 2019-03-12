local World, Class, Collider, Shape, lp, lg = {}, {}, {}, {}, love.physics, love.graphics
local _funcs = {__gc=0,__eq=0,__index=0,__tostring=0,isDestroyed=0,testPoint=0,getType=0,raycast=0,destroy=0,setUserData=0,getUserData=0,release=0,type=0,typeOf=0}

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

local function _set_funcs(obj1, obj2) for k, v in pairs(obj2.__index) do if not _funcs[k] then obj1[k] = function(obj1, ...) return v(obj2, ...) end end end end
local function _uuid() local fn = function() local r = math.random(16) return ("0123456789ABCDEF"):sub(r, r) end return ("xxxxxxxxxxxxxxxx"):gsub("[x]", fn) end
local function _callback(fix1, fix2, contact, callback, ...)
    local body1, body2   = fix1:getBody()     , fix2:getBody()
    local shape1, shape2 = fix1:getUserData() , fix2:getUserData()
    local coll1, coll2   = body1:getUserData(), body2:getUserData()
    local class1, class2 = coll1:get_class()  , coll2:get_class()
    local multi_contact = false

    for k,v in pairs(body1:getContacts()) do for k2,v2 in pairs(body2:getContacts()) do if v == v2 and v ~= contact then multi_contact = true break end end end

    if not multi_contact then 
        if callback == "_enter" or callback == "_exit" then 
            if class1 then class1[callback](class1, coll1, shape1, class2, coll2, shape2, contact, ...) end  
            if class2 then class2[callback](class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
            if coll1  then coll1[callback]( class1, coll1, shape1, class2, coll2, shape2, contact, ...) end
            if coll2  then coll2[callback]( class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
        else -- can use _pre & _post callbacks only if collider countain one shape
            local count1, count2 = 0, 0
            for k,v in pairs(coll1._shapes) do count1 = count1 + 1 end
            for k,v in pairs(coll2._shapes) do count2 = count2 + 1 end
            if coll1 and count1 == 1 then 
                if class1 then class1[callback](class1, coll1, shape1, class2, coll2, shape2, contact, ...) end
                coll1[callback]( class1, coll1, shape1, class2, coll2, shape2, contact, ...)
            end
            if coll2 and count2 == 1 then 
                if class2 then class2[callback](class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
                coll2[callback]( class2, coll2, shape2, class1, coll1, shape1, contact, ...)
            end
        end
    end
    if shape1 then shape1[callback](class1, coll1, shape1, class2, coll2, shape2, contact, ...) end
    if shape2 then shape2[callback](class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
end
local function _enter(fix1, fix2, contact)     return _callback(fix1, fix2, contact, "_enter")     end
local function _exit(fix1, fix2, contact)      return _callback(fix1, fix2, contact, "_exit")      end
local function _pre(fix1, fix2, contact)       return _callback(fix1, fix2, contact, "_pre")       end
local function _post(fix1, fix2, contact, ...) return _callback(fix1, fix2, contact, "_post", ...) end -- ... => normal_impulse1, tangent_impulse1, normal_impulse2, tangent_impulse2

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:__call(xg,yg,sleep)
    local obj = {}
        -------------------------------------
        obj._b2d        = lp.newWorld(xg,yg,sleep)  
        obj._colliders = {}                  
        obj._joints    = {}
        obj._classes   = {}                
        -------------------------------------
        obj._b2d:setCallbacks(_enter, _exit, _pre, _post)
        _set_funcs(obj, obj._b2d)
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
    for _, joint in ipairs(self._b2d:getJoints()) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then lg.circle('line', x1, y1, 6) end
        if x2 and y2 then lg.circle('line', x2, y2, 6) end
    end
    lg.setColor(_r, _g, _b, _a)
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_class(tag) 
    self._classes[tag] = setmetatable({
            _enter = function() end,
            _exit  = function() end,
            _pre   = function() end,
            _post  = function() end,
        }, {__index = Class, __call = tag}) 

    return self._classes[tag] 
end


function World:get_class(tag) return self._classes[tag] end

function Class:set_enter(fn) self._enter = fn return self end
function Class:set_exit(fn)  self._exit  = fn return self end
function Class:set_pre(fn)   self._pre   = fn return self end
function Class:set_post(fn)  self._post  = fn return self end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_collider(tag, collider_type, ...)
    local _w, _tag, _ct, _a, _b, _s, _collider = self._b2d, tag or uuid(), collider_type, {...}, nil, nil, setmetatable({}, {__index = Collider})
    if self._colliders[_tag] then print("Collider called " .. _tag .. " already exist."); _tag = uuid() end
    if     _ct == "circle"    then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[4] or "dynamic"), lp.newCircleShape(_a[3])
    elseif _ct == "rectangle" then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[6] or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] or 0)
    elseif _ct == "polygon"   then _b, _s = lp.newBody(_w,     0,     0, _a[2] or "dynamic"), lp.newPolygonShape(unpack(_a[1]))
    elseif _ct == "line"      then _b, _s = lp.newBody(_w,     0,     0, _a[5] or "static" ), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _ct == "chain"     then _b, _s = lp.newBody(_w,     0,     0, _a[3] or "static" ), lp.newChainShape(_a[1], unpack(_a[2]))  end
    -----------------------------
    _collider._world  = self
    _collider._id     = uuid()    
    _collider._tag    = _tag
    _collider._class  = false       
    _collider._body   = _b       
    _collider._shapes = {}       
    _collider._enter  = function() end  
    _collider._exit   = function() end  
    _collider._pre    = function() end  
    _collider._post   = function() end  
    -----------------------------
    _collider._shapes["main"] = setmetatable({   
        _tag     = "main",
        _id      = uuid(), 
        _shape   = _s, 
        _fixture = lp.newFixture(_b, _s, 1),
        _enter  = function() end,
        _exit   = function() end,
        _pre    = function() end,
        _post   = function() end  
    }, {__index = Shape})
    _set_funcs(_collider, _collider._body)
    _set_funcs(_collider, _collider._shapes["main"]._shape)
    _set_funcs(_collider, _collider._shapes["main"]._fixture)
    _set_funcs(_collider._shapes["main"], _collider._shapes["main"]._shape)
    _set_funcs(_collider._shapes["main"], _collider._shapes["main"]._fixture)
    _collider._body:setUserData(_collider)
    _collider._shapes["main"]._fixture:setUserData(_collider._shapes["main"])
    self._colliders[_tag] = _collider 
    return _collider
end
function World:add_circle(tag, x, y, r, move_type)          return self:add_collider(tag, "circle"   , x, y, r, move_type)        end
function World:add_rectangle(tag, x, y, w, h, r, move_type) return self:add_collider(tag, "rectangle", x, y, w, h, r, move_type)  end
function World:add_polygon(tag, vertices, move_type)        return self:add_collider(tag, "polygon"  , vertices, move_type)       end
function World:add_line(tag, x1, y1, x2, y2, move_type)     return self:add_collider(tag, "line"     , x1, y1, x2, y2, move_type) end
function World:add_chain(tag, loop, vertices, move_type)    return self:add_collider(tag, "chain"    , loop, vertices, move_type) end
function World:get_collider(tag)              return self._colliders[tag]                         end
function World:get_shape(coll_tag, shape_tag) return self._colliders[coll_tag]._shapes[shape_tag] end
function World:remove_collider(tag) if not self._colliders[tag] then print("Collider: " .. tag .. " doesn't exist.") else self._colliders[tag]:destroy() end return self end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_joint(tag, joint_type, col1, col2, ...)
    local _tag, _jt, _joint = tag or _uuid(), joint_type, nil
    if self._joints[_tag] then print("Joint: " .. _tag .. " already exist."); _tag = uuid() end
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
    self._joints[_tag] = _joint 
    return _joint 
end
function World:get_joint(tag) return self._joints[tag] end
function World:remove_joint(tag)
    if not self._joints[tag] then print("Joint: " .. tag .. " doesn't exist.") return end
    self._joints[tag]:setUserData(nil)
    self._joints[tag]:destroy()
    self._joints[tag] = nil
    return self
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Collider:add_shape(tag, shape_type, ...)
    local _tag, _st,  _a, _shape = tag or _uuid(), shape_type, {...}, nil
    if self._shapes[_tag] then print("Shape: " .. _tag .. " already exist."); _tag = uuid() end
    if     _st == "circle"    then _shape = lp.newCircleShape(_a[1], _a[2], _a[3])
    elseif _st == "rectangle" then _shape = lp.newRectangleShape(_a[1], _a[2], _a[3], _a[4], _a[5])
    elseif _st == "polygon"   then _shape = lp.newPolygonShape(unpack(_a[1]))
    elseif _st == "line"      then _shape = lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _st == "chain"     then _shape = lp.newChainShape(_a[1], unpack(_a[2])) end

    local obj = {}
    -------------------------------------------------------
    obj._tag      = _tag  
    obj._id       = uuid()                         
    obj._shape    = _shape                                  
    obj._collider = self                                    
    obj._fixture  = lp.newFixture(self._body, _shape, 1)    
    obj._enter    = function() end                          
    obj._exit     = function() end                          
    obj._pre      = function() end                          
    obj._post     = function() end                          
    -------------------------------------------------------
    self._shapes[_tag] = setmetatable(obj, {__index = Shape})
    _set_funcs(self._shapes[_tag], self._shapes[_tag]._shape)
    _set_funcs(self._shapes[_tag], self._shapes[_tag]._fixture)
    self._shapes[_tag]._fixture:setUserData(self._shapes[_tag])
    return self._shapes[_tag]
end
function Collider:add_circle(tag, x, y, r)       return self:add_shape(tag, "circle"   , x, y, r)        end
function Collider:add_rectangle(tag, x, y, w, h) return self:add_shape(tag, "rectangle", x, y, w, h)     end
function Collider:add_polygon(tag, vertices)     return self:add_shape(tag, "polygon"  , vertices)       end
function Collider:add_line(tag, x1, y1, x2, y2)  return self:add_shape(tag, "line"     , x1, y1, x2, y2) end
function Collider:add_chain(tag, loop, vertices) return self:add_shape(tag, "chain"    , loop, vertices) end
function Collider:get_shape(tag) return self._shapes[tag] end
function Collider:remove_shape(tag) if not self._shapes[tag] then print("Shape: " .. tag .. " doesn't exist.") else self._shapes[tag]:destroy() end return self end
function Collider:set_enter(fn) self._enter = fn return self end
function Collider:set_exit(fn)  self._exit  = fn return self end
function Collider:set_pre(fn)   self._pre   = fn return self end
function Collider:set_post(fn)  self._post  = fn return self end
function Collider:set_class(class) if self._world._classes[class] then self._class = class end return self end
function Collider:get_class() return self._world._classes[self._class] end
function Collider:destroy()
    if self._body:isDestroyed() then print("Collider: " .. self._tag .. " already destroyed.") return end
    for k,v in pairs(self._shapes) do v._fixture:setUserData(nil); v._fixture:destroy(); v = nil end
    self._body:setUserData(nil); self._body:destroy()
    for _,v in pairs(self) do v = nil end
    self._world._colliders[self._tag] = nil
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Shape:set_enter(fn) self._enter = fn return self end
function Shape:set_exit(fn)  self._exit  = fn return self end
function Shape:set_pre(fn)   self._pre   = fn return self end
function Shape:set_post(fn)  self._post  = fn return self end
function Shape:destroy()
    if self._fixture:isDestroyed() then print("Shape: " .. self._tag .. " already destroyed.") return end 
    self._fixture:setUserData(nil); self._fixture:destroy()
    for _,v in pairs(self) do v = nil end
    self._collider._shapes[self._tag] = nil
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

return setmetatable({}, World)
