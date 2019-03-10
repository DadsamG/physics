
function uuid()
    local fn = function(x)
        local r = math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789ABCDEF"):sub(r, r)
    end
    return (("xxxxxxxx"):gsub("[x]", fn))
end

function random(x, y) 
    if type(x) == "table" then return x[random(#x)] end
    return love.math.random(x, y) 
end

function pause()
    local input = io.read()
    while input ~= "" do xpcall(function()loadstring(input)() end, function() print("Invalid function") end); input = io.read() end
end

-------------------------------
-------------------------------
-------------------------------

function recursive_require(path)
    for _,v in pairs(love.filesystem.getDirectoryItems(path)) do
        if love.filesystem.getInfo(path .. "/" .. v).type == "file" then require(path .. "/" .. v:gsub(".lua", "")) end
    end
    for _,v in pairs(love.filesystem.getDirectoryItems(path)) do
        if love.filesystem.getInfo(path .. "/" .. v).type == "directory" then require_all(path .. "/" .. v) end
    end
end

function require_all(path)
    for _,v in pairs(love.filesystem.getDirectoryItems(path)) do
        if love.filesystem.getInfo(path .. "/" .. v).type == "file" then require(path .. "/" .. v:gsub(".lua", "")) end
    end
end

-------------------------------
-------------------------------
-------------------------------

function table_copy(t)
    local copy = {}
        if type(t) == 'table' then
            for k, v in next, t, nil do copy[table_copy(k)] = table_copy(v) end
            setmetatable(copy, table_copy(getmetatable(t)))
        else copy = table end
    return copy
end

function table_print(t, indent)
    local indent = indent or 0
    if type(t) == "table" then 
        for k, v in pairs(t) do 
            io.write(string.rep(" ", indent))
            io.write( "[" .. k .. "] = ")
            if type(v) == "table" then print("{}") end
            table_print(v, indent + 6)
        end
    else print(t) end
end

-------------------------------
-------------------------------
-------------------------------

function draw(func, x, y, angle, sx, sy, kx, ky)
    love.graphics.push()
    love.graphics.scale(sx or 1, sy or 1)
    love.graphics.shear( kx or 0, ky or 0)
    love.graphics.translate(x or 0, y or 0)
    love.graphics.rotate(angle or 0)
    func()
    love.graphics.pop()
end

function draw_center(x) return -(x) / 2 end

function draw_rectangle(style, x, y, width, height, angle) draw(function() lg.rectangle(style,draw_center(width),draw_center(height), width, height) end, x, y, angle) end

-------------------------------
-------------------------------
-------------------------------

function clamp(x, min, max) return x < min and min or (x > max and max or x) end

function lerp(a, b, x, dt) return a + (b - a ) * (1.0 - math.exp(-x * dt)) end

-------------------------------
-------------------------------
-------------------------------

-- local function _callback(fix1, fix2, contact, callback, ...)
--     local body1, body2   = fix1:getBody()     , fix2:getBody()
--     local shape1, shape2 = fix1:getUserData() , fix2:getUserData()
--     local coll1, coll2   = body1:getUserData(), body2:getUserData()
--     local class1, class2 = coll1:get_class()  , coll2:get_class()


--     if class1 then class1[callback](class1, coll1, shape1, class2, coll2, shape2, contact, ...) end  
--     if class2 then class2[callback](class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
--     if coll1  then coll1[callback]( class1, coll1, shape1, class2, coll2, shape2, contact, ...) end
--     if coll2  then coll2[callback]( class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
--     if shape1 then shape1[callback](class1, coll1, shape1, class2, coll2, shape2, contact, ...) end
--     if shape2 then shape2[callback](class2, coll2, shape2, class1, coll1, shape1, contact, ...) end
-- end