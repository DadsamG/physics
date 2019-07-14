# PHYSICS

## What is it ?
**physics.lua** is a **LÖVE** framework library that wrap the **[love.physics](https://love2d.org/wiki/love.physics)** module to make it easier to use. It's a complete rewrite of the **[Windfield](https://github.com/adnzzzzZ/windfield)** library. Before using it I recommand checking out how the **love.physics** module works. 

**Why use it instead of Windfield ?**
- Some new features !
- Windfield is no longer maintened
- Less LOC, no dependencies
- I've found some bugs in Windfield (mainly collision callbacks)

**XXX don't work, I want XXX feature**
- I'm open to suggestions, contact me here or on twitter ([@4v0v_](https://twitter.com/4v0v_/)).

## Basics

There are the concepts of this library :
- **World** : One world equals one physic simulation, it's the hightest level container.
- **Colliders** : Base object of the library, reside in the world, react to the world physic and other colliders. When created it's composed 1 **main** **physics.lua Shape** and contain all(*see Gotcha part) the functions of a LÖVE physics [Body](https://love2d.org/wiki/Body), [Fixture](https://love2d.org/wiki/Fixture) and [Shape](https://love2d.org/wiki/Shape) as well as additional ones defined by this library.
- **Shapes** : A collider can have multiples shapes, two triangles and one rectangle for exemple. A **physics.lua** Shape  is not the same as a **love.physics** Shape, more on that in the **Shape** part.
- **Classes** : A collider can have ONE class, the class tell what other class the collider can collide with.
- **Collision callbacks** : 
  - **enter** : what to do when a collider/shape begin touching another one.
  - **exit** : what to do when a collider/shape stop touching another one.
  - **presolve** : what to do each frame a collider/shape is touching another one before the physics is applied.
  - **postsolve** : what to do each frame a collider/shape is touching another one after the physics is applied.
- **Joints** : Attach 2 colliders together in different ways, see [Joints](https://love2d.org/wiki/Joint)
- **Queries** : Get all the colliders from a certain area



Minimal exemple:
```lua
function love.load()
    Physics = require("physics")

    world = Physics()

    local rect = world:addRectangle(0, 0, 100, 100, 0.3)
    rect:applyAngularImpulse(20000)
    rect:applyLinearImpulse(1000, 1000)
end

function love.update(dt) 
    world:update(dt) 
end

function love.draw() 
    world:draw() 
end
```


## API

### World 
```lua
Physics = require("physics")
```
---
```lua 
World = Physics([xg, yg, sleep])
```
- `xg(number)`
- `yg(number)`
- `sleep(boolean)`

Create a new world, same as **love.physics.newWorld**.

---
```lua
World:draw()
```

Draw colliders, joints and queries, useful for debug and fast prototyping.

---
```lua 
World:update(dt)
```
- `dt(number)`

Update the world, put this into the **love.update** function.

---
```lua 
World:setEnter(function(shape1, shape2, contact) end)
World:setExit(function(shape1, shape2, contact) end)
World:setPresolve(function(shape1, shape2, contact) end)
World:setPostsolve(function(shape1, shape2, contact) end)
```

Global callback functions that is going to be called every time a collider touch (**enter**) stop touching (**exit**) is touching before the physics is applied (**presolve**), after the physics is applied (**postsolve**).

!!! **shape1** and **shape2** are shapes from this library, **NOT** love.physics shapes !!!

---
```lua 
World:addClass(name, ignore)
```
- `name(string)`
- `ignore(table)`
Add a class and what other classes it ignore, it's a wrapper around box2d categories / masks as explained here:
https://love2d.org/forums/viewtopic.php?f=4&t=75441

Exemple:
```lua
world:addClass("my_class1", {"my_class1","my_class2"})
world:addClass("my_class2")
world:addClass("my_class3", {"my_class2"})
```
- colliders with the class **my_class1** are only going to collide with colliders with class **my_class3**.
- colliders with the class **my_class2** are only going to collide with colliders with class **my_class2**.
- colliders with the class **my_class3** are going to collide with colliders with class **my_class1** and **my_class3**.

---
```lua
World:addJoint(joint_type, collider1, collider2, ...)
```
Add a joint that contains all the love.physics [Joint](https://love2d.org/wiki/Joint) functions.

---
```lua
World:addCollider(collider_type, ...)
```
Add a collider to the world, a collider is an oject that contains a body, an a "main" shape. 
You can execute all fixtures/body/shapes functions on it.

```lua
World:addRectangle(x, y, width, height, angle, type)
World:addCircle(x, y, radius, type)
World:addPolygon(x, y, vertices, type)
World:addLine(x1, y1, x2, y2, type)
World:addChain(loop, vertices, type)
```
Shortcut to `World:addCollider(...)`, default **type** for **rectangle**, **circle**, **polygon** is **dynamic** and **line**, **chain** is **static**.

## Queries

```lua
World:queryRectangle(x,y, width, height, class)
World:queryCircle(x, y, radius, class)
World:queryPolygon(verticles, class)
World:queryLine(x1, y1, x2, y2, class)
```

## Colliders

```lua 
Collider:setEnter(function(shape1, shape2, contact) end)
CollidersetExit(function(shape1, shape2, contact) end)
Collider:setPresolve(function(shape1, shape2, contact) end)
Collider:setPostsolve(function(shape1, shape2, contact) end)
```

## Shapes



# Gotcha
Some functions are used internaly or have the same name :
don't use : 
  -setUserData
  -getUserData
use from ._fixture, ._shape, ._body :
  -isDestroyed
  -testPoint
  -getType
  -raycast
  -destroy
  -release
  -type
  -typeOf

To use Contact:getNormal() you need to identify witch shape is the first and witch is second
