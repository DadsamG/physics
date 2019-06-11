local World, Collider, Shape, lg, lp = {}, {}, {}, love.graphics, love.physics
local _uid = function() local fn = function() local r = math.random(16) return ("0123456789ABCDEF"):sub(r, r) end return ("xxxxxxxxxxxxxxxx"):gsub("[x]", fn) end
local _set_funcs = function(a, ...) 
    local args = {...}
    local _f = {__gc=0,__eq=0,__index=0,__tostring=0,isDestroyed=0,testPoint=0,getType=0,raycast=0,destroy=0,setUserData=0,getUserData=0,release=0,type=0,typeOf=0}
    for _, arg in pairs(args) do for k, v in pairs(arg.__index) do if not _f[k] then a[k] = function(a, ...) return v(arg, ...) end end end end
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:new(xg, yg, sleep)
    local function _callback(callback, fix1, fix2, contact, ...)
        if fix1:getUserData() and fix2:getUserData() then
            local shape1, shape2 = fix1:getUserData() , fix2:getUserData()
            local coll1 , coll2  = fix1:getBody():getUserData(), fix2:getBody():getUserData()
            local ctitle         = coll1._id  .. "\t" .. coll2._id
            local stitle         = shape1._id .. "\t" .. shape2._id
            local world          = coll1._world

            world[callback](shape1, shape2, contact, ...)
            fix1:getUserData()[callback](shape1, shape2, contact, ...)        
            fix2:getUserData()[callback](shape2, shape1, contact, ...) 
            
            if callback == "_enter" then 
                if not world._collisions[ctitle] then 
                    world._collisions[ctitle] = {}
                    coll1._enter(shape1, shape2, contact)
                    coll2._enter(shape2, shape1, contact)
                end
                table.insert(world._collisions[ctitle], stitle)
            elseif callback == "_exit" then
                for i,v in pairs(world._collisions[ctitle]) do if v == stitle then table.remove(world._collisions[ctitle], i) break end end
                if #world._collisions[ctitle] == 0 then 
                    world._collisions[ctitle] = nil
                    coll1._exit(shape1, shape2, contact)
                    coll2._exit(shape2, shape1, contact)
                end
            end
        end
    end
    local function _enter(fix1, fix2, contact)      _callback("_enter", fix1, fix2, contact)      end
    local function _exit(fix1, fix2, contact)       _callback("_exit" , fix1, fix2, contact)      end
    local function _pre(fix1, fix2, contact)        _callback("_pre"  , fix1, fix2, contact)      end
    local function _post(fix1, fix2, contact, ...)  _callback("_post" , fix1, fix2, contact, ...) end -- ... => normal_impulse1, tangent_impulse1, normal_impulse2, tangent_impulse2
    -----------------------------
    local obj = {
        _b2d          = lp.newWorld(xg, yg, sleep),
        _colliders    = {},
        _joints       = {},
        _classes      = {},
        _classes_mask = {},
        _collisions   = {},
        _enter        = function() end,
        _exit         = function() end,
        _pre          = function() end,
        _post         = function() end
    }
    -----------------------------
    _set_funcs(obj, obj._b2d)
    setmetatable(obj, {__index = World})
    obj:setCallbacks(_enter, _exit, _pre, _post)
    obj:add_class("Default")

    return obj
end
function World:draw()
    local _r, _g, _b = lg.getColor()
    -- Colliders --
    lg.setColor(1, 1, 1)
    for k1,v1 in pairs(self:getBodies()) do for k2, v2 in pairs(v1:getFixtures()) do 
        if     v2:getShape():getType() == "circle"  then lg.circle("line", v1:getX(), v1:getY(), v2:getShape():getRadius())
        elseif v2:getShape():getType() == "polygon" then lg.polygon("line", v1:getWorldPoints(v2:getShape():getPoints()))
        else   local _p = {v1:getWorldPoints(v2:getShape():getPoints())}; for i=1, #_p, 2 do if i < #_p-2 then lg.line(_p[i], _p[i+1], _p[i+2], _p[i+3]) end end end
    end end
    -- Joints --
    lg.setColor(1, 0.5, 0.25)
    for _, joint in ipairs(self:getJoints()) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then lg.circle('line', x1, y1, 6) end
        if x2 and y2 then lg.circle('line', x2, y2, 6) end
    end
    lg.setColor(_r, _g, _b)
end
function World:set_enter(fn)     self._enter = fn end
function World:set_exit(fn)      self._exit  = fn end
function World:set_presolve(fn)  self._pre   = fn end
function World:set_postsolve(fn) self._post  = fn end
function World:add_class(name, ignore)
    local function sa(t1, t2) for k in pairs(t1) do if not t2[k] then return false end end for k in pairs(t2) do if not t1[k] then return false end end return true end
    local function a(g) local r = {} for l, _ in pairs(g) do r[l] = {} for k,v in pairs(g) do for _ ,v2 in pairs(v) do if v2 == l then r[l][k] = "" end end end end return r end
    local function b(g) local r = {} for k,v in pairs(g) do table.insert(r, v) end for i = #r, 1,-1 do  local s = false for j = #r, 1, -1 do if i ~= j and sa(r[i], r[j]) then s = true end end if s then table.remove( r, i ) end end return r end
    local function c(t1, t2) local r = {} for i, v in pairs(t2) do for l,v2 in pairs(t1) do if sa(v, v2) then r[l] = i end end end return r end
    -----------------------------
    local ignore = ignore or {}
    self._classes[name] = ignore
    self._classes_mask = c(a(self._classes), b(a(self._classes)))

    for k,v in pairs(self._colliders) do v:set_class(v._class) end
    return self
end
function World:add_joint(joint_type, col1, col2, ...)
    local _jt,_joint, _j  = joint_type, {}
    if     _jt == "distance"  then _j = lp.newDistanceJoint(col1._body, col2._body, ...)
    elseif _jt == "friction"  then _j = lp.newFrictionJoint(col1._body, col2._body, ...)
    elseif _jt == "gear"      then _j = lp.newGearJoint(col1._joint, col2._joint, ...)    
    elseif _jt == "motor"     then _j = lp.newMotorJoint(col1._body, col2._body, ...)             
    elseif _jt == "mouse"     then _j = lp.newMouseJoint(col1._body, col2, ...) -- col2 = x, ... = y      
    elseif _jt == "prismatic" then _j = lp.newPrismaticJoint(col1._body, col2._body, ...)
    elseif _jt == "pulley"    then _j = lp.newPulleyJoint(col1._body, col2._body, ...)  
    elseif _jt == "revolute"  then _j = lp.newRevoluteJoint(col1._body, col2._body, ...)
    elseif _jt == "rope"      then _j = lp.newRopeJoint(col1._body, col2._body, ...)    
    elseif _jt == "weld"      then _j = lp.newWeldJoint(col1._body, col2._body, ...)    
    elseif _jt == "wheel"     then _j = lp.newWheelJoint(col1._body, col2._body, ...) end
    -----------------------------
    _joint._id = _uid()
    _joint._joint = _j
    -----------------------------
    _set_funcs(_joint, _joint._joint) 
    self._joints[_joint._id] = _joint

    return _joint 
end
function World:add_collider(collider_type, ...)
    local _w, _ct, _a, _collider, _b, _s = self._b2d, collider_type, {...}, {}
    if     _ct == "circle"    then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[4] or "dynamic"), lp.newCircleShape(_a[3])
    elseif _ct == "rectangle" then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[6] or "dynamic"), lp.newRectangleShape(0, 0, _a[3], _a[4], _a[5] or 0)
    elseif _ct == "polygon"   then _b, _s = lp.newBody(_w, _a[1], _a[2], _a[4] or "dynamic"), lp.newPolygonShape(unpack(_a[3]))
    elseif _ct == "line"      then _b, _s = lp.newBody(_w,     0,     0, _a[5] or "static" ), lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _ct == "chain"     then _b, _s = lp.newBody(_w,     0,     0, _a[3] or "static" ), lp.newChainShape(_a[1], unpack(_a[2]))  end
    -----------------------------
    _collider._world   = self
    _collider._id      = _uid()
    _collider._class   = ""
    _collider._enter   = function() end
    _collider._exit    = function() end
    _collider._body    = _b
    _collider._shapes  = {
        main = {
            _collider = _collider,
            _id    = "main_" .. _collider._id, 
            _shape   = _s,
            _fixture = lp.newFixture(_b, _s, 1),
            _enter   = function() end,
            _exit    = function() end,
            _pre     = function() end,
            _post    = function() end
        }
    }
    -----------------------------
    _collider._shapes["main"]._fixture:setUserData(_collider._shapes["main"])
    _collider._body:setUserData(_collider)
    _set_funcs(_collider, _collider._body, _collider._shapes["main"]._shape, _collider._shapes["main"]._fixture)
    setmetatable(_collider._shapes["main"], {__index = Shape})
    setmetatable(_collider, {__index = Collider})
    _collider:set_class("Default")
    self._colliders[_collider._id] = _collider

    return _collider
end
function World:add_circle(x, y, r, type)            return self:add_collider("circle"   , x, y, r, type)          end
function World:add_rectangle(x, y, w, h, rad, type) return self:add_collider("rectangle", x, y, w, h, rad, type)  end
function World:add_polygon(x, y, vertices, type)    return self:add_collider("polygon"  , x, y, vertices, type)   end
function World:add_line(x1, y1, x2, y2, type)       return self:add_collider("line"     , x1, y1, x2, y2, type)   end
function World:add_chain(loop, vertices, type)      return self:add_collider("chain"    , loop, vertices, type)   end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Collider:set_class(class)
    local class = class or "Default"
    assert( self._world._classes[class] , "Class "  .. class .. " is undefined.")
    self._class = class
    local tmask = {}
    for _, v in pairs(self._world._classes[class]) do table.insert(tmask, self._world._classes_mask[v]) end
    for k, v in pairs(self._shapes) do  v._fixture:setCategory(self._world._classes_mask[class]) v._fixture:setMask(unpack(tmask))end
    return self
end
function Collider:set_enter(fn) self._enter = fn return self end
function Collider:set_exit(fn)  self._exit  = fn return self end
function Collider:get_class()     return self._class         end
function Collider:get_id()        return self._id            end
function Collider:get_shape(name) return self._shape[name]   end
function Collider:set_id(id)
    assert(not self._world._colliders[id], "Collider " .. id .. " already exists.")
    self._world._colliders[self._id] = nil 
    self._id = id
    self._world._colliders[self._id] = self 
end
function Collider:add_shape(name, shape_type, ...)
    assert(not self._shapes[name], "Collider already have a shape called '" .. name .."'.") 
    local _st, _a, _shape = shape_type, {...}
    if     _st == "circle"    then _shape = lp.newCircleShape(_a[1], _a[2], _a[3])
    elseif _st == "rectangle" then _shape = lp.newRectangleShape(_a[1], _a[2], _a[3], _a[4], _a[5])
    elseif _st == "polygon"   then _shape = lp.newPolygonShape(unpack(_a[1]))
    elseif _st == "line"      then _shape = lp.newEdgeShape(_a[1], _a[2], _a[3], _a[4])
    elseif _st == "chain"     then _shape = lp.newChainShape(_a[1], unpack(_a[2])) end
    -----------------------------
    self._shapes[name] = {
        _name     = name,
        _id       = name .. "_" .. self._id,
        _collider = self,
        _shape    = _shape,
        _fixture  = lp.newFixture(self._body, _shape, 1),
        _enter    = function() end,
        _exit     = function() end,
        _pre      = function() end,
        _post     = function() end
    }
    -----------------------------
    _set_funcs(self._shapes[name], self._body, self._shapes[name]._fixture, self._shapes[name]._shape)
    self._shapes[name]._fixture:setUserData(self._shapes[name])
    local tmask = {} for _, v in pairs(self._world._classes[self._class]) do table.insert(tmask, self._world._classes_mask[v]) end
    self._shapes[name]._fixture:setCategory(self._world._classes_mask[self._class])
    self._shapes[name]._fixture:setMask(unpack(tmask))
    return setmetatable(self._shapes[name], {__index = Shape})
end
function Collider:remove_shape(name)
    assert(self._shapes[name], "Shape '" .. name .. "' doesn't exist.")
    for k, v in pairs(self._world._collisions) do 
        if k:find(self._id) then 
            for i = #v, 1, -1 do 
                if v[i]:find(self._shapes[name]._id) then table.remove(self._world._collisions[k], i) end
            end
        end
        if #v == 0 then self._world._collisions[k] = nil end
    end

    self._shapes[name]._fixture:setUserData(nil)
    self._shapes[name]._fixture:destroy()
    self._shapes[name]._fixture  = nil
    self._shapes[name]._collider = nil
    self._shapes[name]._shape    = nil
    self._shapes[name]           = nil
end

function Collider:destroy()
    for k, v in pairs(self._world._collisions) do if k:find(self._id) then self._world._collisions[k] = nil end end
    self._world._colliders[self._id] = nil 
    self._world = nil

    for k,v in pairs(self._shapes) do 
        v._fixture:setUserData(nil)
        v._fixture:destroy()
        v._fixture  = nil
        v._shape    = nil
        v._collider = nil
    end
    self._body:setUserData(nil)
    self._body:destroy()
    self._body = nil
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Shape:set_enter(fn)     self._enter = fn       end
function Shape:set_exit(fn)      self._exit  = fn       end
function Shape:set_presolve(fn)  self._pre   = fn       end
function Shape:set_postsolve(fn) self._post  = fn       end
function Shape:get_collider() return self._collider     end
function Shape:get_class() return self._collider._class end
function Shape:get_id()    return self._collider._id    end
function Shape:destroy() self._collider:remove_shape(self._name) end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

return setmetatable({}, {__call = World.new})