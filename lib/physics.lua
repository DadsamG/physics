local world = {}



function set_funcs(mainobject, subobject)
    for k, v in pairs(subobject.__index) do
        if-- k:find("__")  == nil and 
            k ~= '__gc' 
        and k ~= '__eq' 
        and k ~= '__index' 
        and k ~= '__tostring' 
        and k ~= 'destroy' 
        and k ~= 'type' 
        and k ~= 'typeOf' 
        and k ~= 'release'
        and k ~= 'getType'
        and k ~= 'rayCast'
        and k ~= 'getUserData'
        and k ~= 'setUserData'
        and k ~= 'isDestroyed'
        and k ~= 'testPoint'
        then
            mainobject[k] = function(mainobject, ...) return v(subobject, ...) end
        end
    end
 end

 
local collider = {}
collider.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
collider.shape = love.physics.newCircleShape( 20)
collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1)


set_funcs(collider, collider.body)
set_funcs(collider, collider.shape)
set_funcs(collider, collider.fixture)