--MIT License (MIT)
--Copyright (c) 2018 SSYGEN

local World, Collider, lp, lg, MLIB = {}, {}, love.physics, love.graphics, require("lib/physics/mlib")

local function _uuid() local fn = function() local r = math.random(16) return ("0123456789ABCDEF"):sub(r, r) end return ("xxxxxxxxxxxxxxxx"):gsub("[x]", fn) end
local function _coll_ensure(class1, a, class2, b) if a.coll_class == class2 and b.coll_class == class1 then return b, a else return a, b end end
local function _coll_if(class1, class2, a, b) if (a.coll_class==class1 and b.coll_class==class2)or(a.coll_class==class2 and b.coll_class==class1) then return true else return false end end
local function _enter(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    if fixture_a:isSensor() and fixture_b:isSensor() then if a and b then for _, coll in ipairs(a.world.collisions.on_enter.sensor) do if _coll_if(coll.type1, coll.type2, a, b) then
        a, b = _coll_ensure(coll.type1, a, coll.type2, b)
        table.insert(a.coll_events[coll.type2], {coll_type = 'enter', collider_1 = a, collider_2 = b, contact = contact})
        if coll.type1 == coll.type2 then table.insert(b.coll_events[coll.type1], {coll_type = 'enter', collider_1 = b, collider_2 = a, contact = contact}) end end end end
    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then for _, coll in ipairs(a.world.collisions.on_enter.non_sensor) do if _coll_if(coll.type1, coll.type2, a, b) then
        a, b = _coll_ensure(coll.type1, a, coll.type2, b)
        table.insert(a.coll_events[coll.type2], {coll_type = 'enter', collider_1 = a, collider_2 = b, contact = contact})
        if coll.type1 == coll.type2 then table.insert(b.coll_events[coll.type1], {coll_type = 'enter', collider_1 = b, collider_2 = a, contact = contact}) end end end end
    end
end
local function _exit(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then for _, coll in ipairs(a.world.collisions.on_exit.sensor) do if _coll_if(coll.type1, coll.type2, a, b) then
        a, b = _coll_ensure(coll.type1, a, coll.type2, b)
        table.insert(a.coll_events[coll.type2], {coll_type = 'exit', collider_1 = a, collider_2 = b, contact = contact})
        if coll.type1 == coll.type2 then table.insert(b.coll_events[coll.type1], {coll_type = 'exit', collider_1 = b, collider_2 = a, contact = contact}) end end end end
    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then for _, coll in ipairs(a.world.collisions.on_exit.non_sensor) do if _coll_if(coll.type1, coll.type2, a, b) then
        a, b = _coll_ensure(coll.type1, a, coll.type2, b)
        table.insert(a.coll_events[coll.type2], {coll_type = 'exit', collider_1 = a, collider_2 = b, contact = contact})
        if coll.type1 == coll.type2 then table.insert(b.coll_events[coll.type1], {coll_type = 'exit', collider_1 = b, collider_2 = a, contact = contact}) end end end end
    end
end
local function _pre(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    if fixture_a:isSensor() and fixture_b:isSensor() then if a and b then for _, coll in ipairs(a.world.collisions.pre.sensor) do if _coll_if(coll.type1, coll.type2, a, b) then
        a, b = _coll_ensure(coll.type1, a, coll.type2, b); a:preSolve(b, contact); if coll.type1 == coll.type2 then b:preSolve(a, contact) end end end end
    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then for _, coll in ipairs(a.world.collisions.pre.non_sensor) do if _coll_if(coll.type1, coll.type2, a, b) then a, b = _coll_ensure(coll.type1, a, coll.type2, b) a:preSolve(b, contact) if coll.type1 == coll.type2 then b:preSolve(a, contact) end end end end
    end
end
local function _post(fixture_a, fixture_b, contact, ni1, ti1, ni2, ti2)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then for _, coll in ipairs(a.world.collisions.post.sensor) do if _coll_if(coll.type1, coll.type2, a, b) then a, b = _coll_ensure(coll.type1, a, coll.type2, b) a:postSolve(b, contact, ni1, ti1, ni2, ti2) if coll.type1 == coll.type2 then b:postSolve(a, contact, ni1, ti1, ni2, ti2) end end end end
    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then if a and b then for _, coll in ipairs(a.world.collisions.post.non_sensor) do 
        if _coll_if(coll.type1, coll.type2, a, b) then      a, b = _coll_ensure(coll.type1, a, coll.type2, b) a:postSolve(b, contact, ni1, ti1, ni2, ti2) if coll.type1 == coll.type2 then b:postSolve(a, contact, ni1, ti1, ni2, ti2) end end end end
    end
end

---------------------------------------------------------------------------------------------
--  <°)))>< <°)))>< <°)))><  ----  <°)))>< <°)))>< <°)))><  ----  <°)))>< <°)))>< <°)))><  --
---------------------------------------------------------------------------------------------

function World:__call(xg, yg, sleep)
    local world = setmetatable({}, {__index = World})
        world._b2d = lp.newWorld(xg, yg, sleep) 
        world.WF                          = WF
        world.draw_query_for_n_frames     = 150
        world.query_debug_drawing_enabled = false
        world.explicit_coll_events        = false
        world.coll_classes                = {}
        world.masks                       = {}
        world.is_sensor_memo              = {}
        world.query_debug_draw            = {}

        world._b2d:setCallbacks(_enter, _exit, _pre, _post)
        world:collisionClear()
        world:add_class('Default')
    for k, v in pairs(world._b2d.__index) do if k~='__gc'and k~='__eq'and k~='__index'and k~='__tostring'and k~='update'and k~='destroy'and k~='type'and k~='typeOf'then world[k] = function(self, ...) return v(self._b2d, ...) end end end
    return world
end
function World:update(dt)
    self:collisionEventsClear()
    self._b2d:update(dt)
end
function World:draw(alpha)
    local r, g, b, a = lg.getColor()
    alpha = alpha or 1
    -- Colliders debug
    lg.setColor(222/255, 222/255, 222/255, alpha)
    local bodies = self._b2d:getBodies()
    for _, body in ipairs(bodies) do
        local fixtures = body:getFixtures()
        for _, fixture in ipairs(fixtures) do
            if fixture:getShape():type() == 'PolygonShape' then lg.polygon('line', body:getWorldPoints(fixture:getShape():getPoints()))
            elseif fixture:getShape():type() == 'EdgeShape' or fixture:getShape():type() == 'ChainShape' then
                local points = {body:getWorldPoints(fixture:getShape():getPoints())}
                for i = 1, #points, 2 do if i < #points-2 then lg.line(points[i], points[i+1], points[i+2], points[i+3]) end end
            elseif fixture:getShape():type() == 'CircleShape' then
                local body_x, body_y = body:getPosition()
                local shape_x, shape_y = fixture:getShape():getPoint()
                local r = fixture:getShape():getRadius()
                lg.circle('line', body_x + shape_x, body_y + shape_y, r, 360)
            end
        end
    end
    lg.setColor(255/255, 255/255, 255/255, alpha)
    -- Joint
    lg.setColor(222/255, 128/255, 64/255, alpha)
    local joints = self._b2d:getJoints()
    for _, joint in ipairs(joints) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then lg.circle('line', x1, y1, 4) end
        if x2 and y2 then lg.circle('line', x2, y2, 4) end
    end
    lg.setColor(255/255, 255/255, 255/255, alpha)

    -- Query debug
    lg.setColor(64/255, 64/255, 222/255, alpha)
    for _, query_draw in ipairs(self.query_debug_draw) do
        query_draw.frames = query_draw.frames - 1
        if query_draw.type == 'circle' then lg.circle('line', query_draw.x, query_draw.y, query_draw.r)
        elseif query_draw.type == 'rectangle' then lg.rectangle('line', query_draw.x, query_draw.y, query_draw.w, query_draw.h)
        elseif query_draw.type == 'line' then lg.line(query_draw.x1, query_draw.y1, query_draw.x2, query_draw.y2)
        elseif query_draw.type == 'polygon' then
            local triangles = love.math.triangulate(query_draw.vertices)
            for _, triangle in ipairs(triangles) do lg.polygon('line', triangle) end
        end
    end
    for i = #self.query_debug_draw, 1, -1 do if self.query_debug_draw[i].frames <= 0 then table.remove(self.query_debug_draw, i) end end
    lg.setColor(r, g, b, a)
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_class(class_name, coll_class)
    if self.coll_classes[class_name] then error('Collision class ' .. class_name .. ' already exists.') end

    if self.explicit_coll_events then
        self.coll_classes[class_name] = coll_class or {}
    else
        self.coll_classes[class_name] = coll_class or {}
        self.coll_classes[class_name].enter = {}
        self.coll_classes[class_name].exit  = {}
        self.coll_classes[class_name].pre   = {}
        self.coll_classes[class_name].post  = {}
        for c_class_name, _ in pairs(self.coll_classes) do
            table.insert(self.coll_classes[class_name].enter, c_class_name)
            table.insert(self.coll_classes[class_name].exit , c_class_name)
            table.insert(self.coll_classes[class_name].pre  , c_class_name)
            table.insert(self.coll_classes[class_name].post , c_class_name)
        end
        for c_class_name, _ in pairs(self.coll_classes) do
            table.insert(self.coll_classes[c_class_name].enter, class_name)
            table.insert(self.coll_classes[c_class_name].exit , class_name)
            table.insert(self.coll_classes[c_class_name].pre  , class_name)
            table.insert(self.coll_classes[c_class_name].post , class_name)
        end
    end
    self:collisionClassesSet()
end
function World:setQueryDebugDrawing(value) self.query_debug_drawing_enabled = value end
function World:setExplicitCollisionEvents(value) self.explicit_coll_events  = value end
function World:collisionClassesSet()
    self:generateCategoriesMasks()

    self:collisionClear()
    local collision_table = self:getCollisionCallbacksTable()
    for class_name, collision_list in pairs(collision_table) do
        for _, collision_info in ipairs(collision_list) do
            if collision_info.type == 'enter' then self:addCollisionEnter(class_name, collision_info.other) end
            if collision_info.type == 'exit' then self:addCollisionExit(class_name, collision_info.other) end
            if collision_info.type == 'pre' then self:addCollisionPre(class_name, collision_info.other) end
            if collision_info.type == 'post' then self:addCollisionPost(class_name, collision_info.other) end
        end
    end

    self:collisionEventsClear()
end
function World:collisionClear()
    self.collisions = {}
    self.collisions.on_enter = {}
    self.collisions.on_enter.sensor = {}
    self.collisions.on_enter.non_sensor = {}
    self.collisions.on_exit = {}
    self.collisions.on_exit.sensor = {}
    self.collisions.on_exit.non_sensor = {}
    self.collisions.pre = {}
    self.collisions.pre.sensor = {}
    self.collisions.pre.non_sensor = {}
    self.collisions.post = {}
    self.collisions.post.sensor = {}
    self.collisions.post.non_sensor = {}
end
function World:collisionEventsClear()
    local bodies = self._b2d:getBodies()
    for _, body in ipairs(bodies) do
        local collider = body:getFixtures()[1]:getUserData()
        collider:collisionEventsClear()
    end
end
function World:addCollisionEnter(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then table.insert(self.collisions.on_enter.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.on_enter.sensor, {type1 = type1, type2 = type2}) end
end
function World:addCollisionExit(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then table.insert(self.collisions.on_exit.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.on_exit.sensor, {type1 = type1, type2 = type2}) end
end
function World:addCollisionPre(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then table.insert(self.collisions.pre.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.pre.sensor, {type1 = type1, type2 = type2}) end
end
function World:addCollisionPost(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then table.insert(self.collisions.post.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.post.sensor, {type1 = type1, type2 = type2}) end
end
function World:doesType1IgnoreType2(type1, type2)
    local collision_ignores = {}
    for class_name, coll_class in pairs(self.coll_classes) do
        collision_ignores[class_name] = coll_class.ignores or {}
    end
    local all = {}
    for class_name, _ in pairs(collision_ignores) do
        table.insert(all, class_name)
    end
    local ignored_types = {}
    for _, collision_class_type in ipairs(collision_ignores[type1]) do
        if collision_class_type == 'All' then
            for _, class_name in ipairs(all) do
                table.insert(ignored_types, class_name)
            end
        else table.insert(ignored_types, collision_class_type) end
    end
    for key, _ in pairs(collision_ignores[type1]) do
        if key == 'except' then
            for _, except_type in ipairs(collision_ignores[type1].except) do
                for i = #ignored_types, 1, -1 do
                    if ignored_types[i] == except_type then table.remove(ignored_types, i) end
                end
            end
        end
    end
    for _, ignored_type in ipairs(ignored_types) do
        if ignored_type == type2 then return true end
    end
end
function World:isCollisionBetweenSensors(type1, type2)
    if not self.is_sensor_memo[type1] then self.is_sensor_memo[type1] = {} end
    if not self.is_sensor_memo[type1][type2] then self.is_sensor_memo[type1][type2] = (self:doesType1IgnoreType2(type1, type2) or self:doesType1IgnoreType2(type2, type1)) end
    if self.is_sensor_memo[type1][type2] then return true
    else return false end
end
function World:generateCategoriesMasks()
    local collision_ignores = {}
    for class_name, coll_class in pairs(self.coll_classes) do collision_ignores[class_name] = coll_class.ignores or {} end
    local incoming = {}
    local expanded = {}
    local all = {}
    for object_type, _ in pairs(collision_ignores) do
        incoming[object_type] = {}
        expanded[object_type] = {}
        table.insert(all, object_type)
    end
    for object_type, ignore_list in pairs(collision_ignores) do for key, ignored_type in pairs(ignore_list) do
        if ignored_type == 'All' then for _, all_object_type in ipairs(all) do table.insert(incoming[all_object_type], object_type) table.insert(expanded[object_type], all_object_type) end elseif type(ignored_type) == 'string' then if ignored_type ~= 'All' then table.insert(incoming[ignored_type], object_type) table.insert(expanded[object_type], ignored_type) end end if key == 'except' then for _, except_ignored_type in ipairs(ignored_type) do for i, v in ipairs(incoming[except_ignored_type]) do if v == object_type then table.remov (incoming[except_ignored_type], i) break end end end for _, except_ignored_type in ipairs(ignored_type) do for i, v in ipairs(expanded[object_type]) do if v == except_ignored_type then table.remove(expanded[object_type], i) break end end end end end end local edge_groups = {} for k, v in pairs(incoming) do table.sort(v, function(a, b) return string.lower(a) < string.lower(b) end) 
    end
    local i = 0
    for k, v in pairs(incoming) do
        local str = ""
        for _, c in ipairs(v) do str = str .. c end
        if not edge_groups[str] then i = i + 1; edge_groups[str] = {n = i} end
        table.insert(edge_groups[str], k)
    end
    local categories = {}
    for k, _ in pairs(collision_ignores) do categories[k] = {} end
    for k, v in pairs(edge_groups) do for i, c in ipairs(v) do categories[c] = v.n end end
    for k, v in pairs(expanded) do
        local category = {categories[k]}
        local current_masks = {}
        for _, c in ipairs(v) do table.insert(current_masks, categories[c]) end
        self.masks[k] = {categories = category, masks = current_masks}
    end
end
function World:getCollisionCallbacksTable()
    local collision_table = {}
    for class_name, coll_class in pairs(self.coll_classes) do
        collision_table[class_name] = {}
        for _, v in ipairs(coll_class.enter or {}) do table.insert(collision_table[class_name], {type = 'enter', other = v}) end
        for _, v in ipairs(coll_class.exit  or {}) do table.insert(collision_table[class_name], {type = 'exit' , other = v}) end
        for _, v in ipairs(coll_class.pre   or {}) do table.insert(collision_table[class_name], {type = 'pre'  , other = v}) end
        for _, v in ipairs(coll_class.post  or {}) do table.insert(collision_table[class_name], {type = 'post' , other = v}) end
    end
    return collision_table
end
function World:_queryBoundingBox(x1, y1, x2, y2)
    local colliders = {}
    local callback = function(fixture) if not fixture:isSensor() then table.insert(colliders, fixture:getUserData()) end return true end
    self._b2d:queryBoundingBox(x1, y1, x2, y2, callback)
    return colliders
end
function World:collisionClassInCollisionClassesList(coll_class, coll_classes) 
    if coll_classes[1] == 'All' then local all_coll_classes = {} for class, _ in pairs(self.coll_classes) do table.insert(all_coll_classes, class) end if coll_classes.except then for _, except in ipairs(coll_classes.except) do for i, class in ipairs(all_coll_classes) do if class == except then  table.remove(all_coll_classes, i) break end end end end for _, class in ipairs(all_coll_classes) do if class == coll_class then return true end end else for _, class in ipairs(coll_classes) do if class == coll_class then return true end end end
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_circle(x, y, r, settings)                  return Collider.new(self, 'Circle', x, y, r, settings)                  end
function World:add_rectangle(x, y, w, h, settings)            return Collider.new(self, 'Rectangle', x, y, w, h, settings)            end
function World:add_polygon(vertices, settings)                return Collider.new(self, 'Polygon', vertices, settings)                end
function World:add_line(x1, y1, x2, y2, settings)             return Collider.new(self, 'Line', x1, y1, x2, y2, settings)             end
function World:add_chain(vertices, loop, settings)            return Collider.new(self, 'Chain', vertices, loop, settings)            end
function World:add_bsgrectangle(x, y, w, h, corner, settings) return Collider.new(self, 'BSGRectangle', x, y, w, h, corner, settings) end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:query_circle(x, y, radius, class_names)
    if not class_names then class_names = {'All'} end
    if self.query_debug_drawing_enabled then table.insert(self.query_debug_draw, {type = 'circle', x = x, y = y, r = radius, frames = self.draw_query_for_n_frames}) end
    local colliders = self:_queryBoundingBox(x-radius, y-radius, x+radius, y+radius) 
    local outs = {}
    for _, collider in ipairs(colliders) do if self:collisionClassInCollisionClassesList(collider.coll_class, class_names) then for _, fixture in ipairs(collider.body:getFixtures()) do if MLIB.polygon.getCircleIntersection(x, y, radius, {collider.body:getWorldPoints(fixture:getShape():getPoints())}) then table.insert(outs, collider) break end end end end
    return outs
end
function World:query_rectangle(x, y, w, h, class_names)
    if not class_names then class_names = {'All'} end
    if self.query_debug_drawing_enabled then table.insert(self.query_debug_draw, {type = 'rectangle', x = x, y = y, w = w, h = h, frames = self.draw_query_for_n_frames}) end
    local colliders = self:_queryBoundingBox(x, y, x+w, y+h) 
    local outs = {}
    for _, collider in ipairs(colliders) do if self:collisionClassInCollisionClassesList(collider.coll_class, class_names) then for _, fixture in ipairs(collider.body:getFixtures()) do if MLIB.polygon.isPolygonInside({x, y, x+w, y, x+w, y+h, x, y+h}, {collider.body:getWorldPoints(fixture:getShape():getPoints())}) then table.insert(outs, collider) break end end end end
    return outs
end
function World:query_polygon(vertices, class_names)
    if not class_names then class_names = {'All'} end
    if self.query_debug_drawing_enabled then table.insert(self.query_debug_draw, {type = 'polygon', vertices = vertices, frames = self.draw_query_for_n_frames}) end
    local cx, cy = MLIB.polygon.getCentroid(vertices)
    local d_max = 0
    for i = 1, #vertices, 2 do local d = MLIB.line.getLength(cx, cy, vertices[i], vertices[i+1]) if d > d_max then d_max = d end end
    local colliders = self:_queryBoundingBox(cx-d_max, cy-d_max, cx+d_max, cy+d_max)
    local outs = {}
    for _, collider in ipairs(colliders) do if self:collisionClassInCollisionClassesList(collider.coll_class, class_names) then for _, fixture in ipairs(collider.body:getFixtures()) do if MLIB.polygon.isPolygonInside(vertices, {collider.body:getWorldPoints(fixture:getShape():getPoints())}) then table.insert(outs, collider) break end end end end
    return outs
end
function World:query_line(x1, y1, x2, y2, class_names)
    if not class_names then class_names = {'All'} end
    if self.query_debug_drawing_enabled then table.insert(self.query_debug_draw, {type = 'line', x1 = x1, y1 = y1, x2 = x2, y2 = y2, frames = self.draw_query_for_n_frames}) end
    local colliders = {}
    local callback = function(fixture, ...) if not fixture:isSensor() then table.insert(colliders, fixture:getUserData()) end return 1 end
    self._b2d:rayCast(x1, y1, x2, y2, callback)
    local outs = {}
    for _, collider in ipairs(colliders) do if self:collisionClassInCollisionClassesList(collider.coll_class, class_names) then table.insert(outs, collider) end end
    return outs
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:add_joint(joint_type, ...)
    local args = {...}
    if args[1].body then args[1] = args[1].body end
    if type(args[2]) == "table" and args[2].body then args[2] = args[2].body end
    local joint = lp['new' .. joint_type](unpack(args))
    return joint
end
function World:remove_joint(joint) joint:destroy() end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function World:destroy()
    local bodies = self._b2d:getBodies()
    for _, body in ipairs(bodies) do
        local collider = body:getFixtures()[1]:getUserData()
        collider:destroy()
    end
    local joints = self._b2d:getJoints()
    for _, joint in ipairs(joints) do joint:destroy() end
    self._b2d:destroy()
    self._b2d = nil
end

---------------------------------------------------------------------------------------------
--  <°)))>< <°)))>< <°)))><  ----  <°)))>< <°)))>< <°)))><  ----  <°)))>< <°)))>< <°)))><  --
---------------------------------------------------------------------------------------------

function Collider.new(world, collider_type, ...)
    local _c, args, shape, fixture = {}, {...}
    _c.id          = _uuid()
    _c.world       = world
    _c.type        = collider_type
    _c.object      = nil
    _c.shapes      = {}
    _c.fixtures    = {}
    _c.sensors     = {}
    _c.coll_events = {}
    _c.coll_stay   = {}
    _c.enter_data  = {}
    _c.exit_data   = {}
    _c.stay_data   = {}
 
    if     _c.type == 'Circle'       then
        _c.coll_class = (args[4] and args[4].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, args[1], args[2], (args[4] and args[4].body_type) or 'dynamic')
        shape = lp.newCircleShape(args[3])
    elseif _c.type == 'Rectangle'    then
        _c.coll_class = (args[5] and args[5].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, args[1] + args[3]/2, args[2] + args[4]/2, (args[5] and args[5].body_type) or 'dynamic')
        shape = lp.newRectangleShape(args[3], args[4])
    elseif _c.type == 'BSGRectangle' then
        _c.coll_class = (args[6] and args[6].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, args[1] + args[3]/2, args[2] + args[4]/2, (args[6] and args[6].body_type) or 'dynamic')
        local w, h, s = args[3], args[4], args[5]
        shape = lp.newPolygonShape({
            -w/2, -h/2 + s, -w/2 + s, -h/2,
             w/2 - s, -h/2, w/2, -h/2 + s,
             w/2, h/2 - s, w/2 - s, h/2,
            -w/2 + s, h/2, -w/2, h/2 - s
        })
    elseif _c.type == 'Polygon'      then
        _c.coll_class = (args[2] and args[2].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, 0, 0, (args[2] and args[2].body_type) or 'dynamic')
        shape = lp.newPolygonShape(unpack(args[1]))
    elseif _c.type == 'Line'         then
        _c.coll_class = (args[5] and args[5].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, 0, 0, (args[5] and args[5].body_type) or 'dynamic')
        shape = lp.newEdgeShape(args[1], args[2], args[3], args[4])
    elseif _c.type == 'Chain'        then
        _c.coll_class = (args[3] and args[3].coll_class) or 'Default'
        _c.body = lp.newBody(_c.world._b2d, 0, 0, (args[3] and args[3].body_type) or 'dynamic')
        shape = lp.newChainShape(args[1], unpack(args[2]))
    end

    -- Define collision classes and attach them to fixture and sensor
    fixture = lp.newFixture(_c.body, shape)
    if _c.world.masks[_c.coll_class] then
        fixture:setCategory(unpack(_c.world.masks[_c.coll_class].categories))
        fixture:setMask(unpack(_c.world.masks[_c.coll_class].masks))
    end
    fixture:setUserData(_c)
    local sensor = lp.newFixture(_c.body, shape)
    sensor:setSensor(true)
    sensor:setUserData(_c)

    _c.shapes['main']   = shape
    _c.fixtures['main'] = fixture
    _c.sensors['main']  = sensor
    _c.shape            = shape
    _c.fixture          = fixture
    _c.preSolve         = function() end
    _c.postSolve        = function() end

    for k, v in pairs(_c.body.__index) do if k~='__gc'and k~='__eq'and k~='__index'and k~='__tostring'and k~='destroy'and k~='type'and k~='typeOf'then _c[k] = function(_c, ...) return v(_c.body, ...) end end end
    for k, v in pairs(_c.fixture.__index) do if k~='__gc'and k~='__eq'and k~='__index'and k~='__tostring'and k~='destroy'and k~='type'and k~='typeOf'then _c[k] = function(_c, ...) return v(_c.fixture, ...) end end end
    for k, v in pairs(_c.shape.__index) do if k~='__gc'and k~='__eq'and k~='__index'and k~='__tostring'and k~='destroy'and k~='type'and k~='typeOf'then _c[k] = function(_c, ...) return v(_c.shape, ...) end end end

    return setmetatable(_c, {__index = Collider})
end
function Collider:collisionEventsClear()
    self.coll_events = {}
    for other, _ in pairs(self.world.coll_classes) do self.coll_events[other] = {} end
end
function Collider:set_class(class_name)
    if not self.world.coll_classes[class_name] then error("Collision class " .. class_name .. " doesn't exist.") end
    self.coll_class = class_name
    for _, fixture in pairs(self.fixtures) do
        if self.world.masks[class_name] then
            fixture:setCategory(unpack(self.world.masks[class_name].categories))
            fixture:setMask(unpack(self.world.masks[class_name].masks))
        end
    end
end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Collider:enter(class)
    local events = self.coll_events[class]
    if events and #events >= 1  then
        for _, e in ipairs(events) do
            if e.coll_type == 'enter' then
                if not self.coll_stay[class] then self.coll_stay[class] = {} end
                table.insert(self.coll_stay[class], {collider = e.collider_2, contact = e.contact})
                self.enter_data[class] = {collider = e.collider_2, contact = e.contact}
                return true
            end
        end
    end
end
function Collider:exit(class)
    local events = self.coll_events[class]
    if events and #events >= 1  then
        for _, e in ipairs(events) do
            if e.coll_type == 'exit' then
                if self.coll_stay[class] then
                    for i = #self.coll_stay[class], 1, -1 do
                        local coll_stay = self.coll_stay[class][i]
                        if coll_stay.collider.id == e.collider_2.id then table.remove(self.coll_stay[class], i) end
                    end
                end
                self.exit_data[class] = {collider = e.collider_2, contact = e.contact}
                return true 
            end
        end
    end
end
function Collider:stay(class) 
    if self.coll_stay[class] 
        then if #self.coll_stay[class] >= 1 then return true end 
    end 
end
function Collider:get_enter_data(class) return self.enter_data[class] end
function Collider:get_exit_data(class)  return self.exit_data[class]  end
function Collider:get_stay_data(class)  return self.coll_stay[class]  end

-------------------------------
--  <°)))>< <°)))>< <°)))><  --
-------------------------------

function Collider:set_presolve(callback)  self.preSolve  = callback end
function Collider:set_postsolve(callback) self.postSolve = callback end
function Collider:set_object(object)      self.object    = object   end
function Collider:get_object() return self.object end
function Collider:add_shape(shape_name, shape_type, ...)
    if self.shapes[shape_name] or self.fixtures[shape_name] then error("Shape/fixture " .. shape_name .. " already exists.") end
    local args = {...}
    local shape = lp['new' .. shape_type](unpack(args))
    local fixture = lp.newFixture(self.body, shape)
    if self.world.masks[self.coll_class] then
        fixture:setCategory(unpack(self.world.masks[self.coll_class].categories))
        fixture:setMask(unpack(self.world.masks[self.coll_class].masks))
    end
    fixture:setUserData(self)
    local sensor = lp.newFixture(self.body, shape)
    sensor:setSensor(true)
    sensor:setUserData(self)

    self.shapes[shape_name]   = shape
    self.fixtures[shape_name] = fixture
    self.sensors[shape_name]  = sensor
end
function Collider:remove_shape(shape_name)
    if not self.shapes[shape_name] then return end
    self.shapes[shape_name] = nil
    self.fixtures[shape_name]:setUserData(nil)
    self.fixtures[shape_name]:destroy()
    self.fixtures[shape_name] = nil
    self.sensors[shape_name]:setUserData(nil)
    self.sensors[shape_name]:destroy()
    self.sensors[shape_name] = nil
end
function Collider:destroy()
    self.coll_stay = nil
    self.enter_data = nil
    self.exit_data = nil
    self:collisionEventsClear()

    self:setObject(nil)
    for name, _ in pairs(self.fixtures) do
        self.shapes[name] = nil
        self.fixtures[name]:setUserData(nil)
        self.fixtures[name] = nil
        self.sensors[name]:setUserData(nil)
        self.sensors[name] = nil
    end
    self.body:destroy()
    self.body = nil
end

return setmetatable({}, World)