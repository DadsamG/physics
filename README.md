
# PHYSICS

<p align="center">
  <img src="https://media.giphy.com/media/hV7bY9nSLmjIXIzuVL/giphy.gif"/>
</p>

**physics.lua** is a **LÖVE 11.2** framework library that wrap the **[love.physics](https://love2d.org/wiki/love.physics)** module to make it easier to use.  It's a complete rewrite of the **[Windfield](https://github.com/adnzzzzZ/windfield)** library.  Before using it I recommand checking out how the **love.physics** module works. 

**Why use it instead of Windfield ?**
- Some new features !
- Windfield is no longer maintained
- Support the latest version of the Löve framework (11.2)
- Less LOC, no dependencies
- Some bugs found in Windfield are corrected (mainly collision callbacks)

_**You can contact me here or on twitter ([@4v0v_](https://twitter.com/4v0v_/)).**_


## Content

- [Basics](#basics)
- [Demos](#demos)
- [API](#basics)
  - [World](#world)
  - [Joints](#joints)
  - [Queries](#queries)
  - [Colliders](#colliders)
  - [Shapes](#shapes)
- [Gotcha](#gotcha)


## Basics
There are the concepts of this library :
- **World** : _Where the physic simulation occurs, it's the hightest level container. Contains all the functions of a **[love.physics world](https://love2d.org/wiki/World)** as well as additional ones defined by this library.._
- **Colliders** : _Base object of the library, react to the world physic and other colliders. Contains all the functions of a **love.physics [body](https://love2d.org/wiki/Body)/[fixture](https://love2d.org/wiki/Fixture)/[shape](https://love2d.org/wiki/Shape)** as well as additional ones defined by this library._
- **Shapes** : _A collider can have multiples **Shapes**. A **Shape** is not the same as a **love.physics shape**._
- **Classes** : _A collider can have **ONE** class, the class tell what other class the collider can collide with. When initialized, a **Collider** have the **Default** class._
- **Collision callbacks** : 
  - **enter** : _What to do when a collider/shape begin touching another one._
  - **exit** : _What to do when a collider/shape stop touching another one._
  - **presolve** : _What to do each frame a collider/shape is touching another one before the physics is applied._
  - **postsolve** : _What to do each frame a collider/shape is touching another one after the physics is applied._
- **Joints** : _Attach 2 colliders together in different ways. Contains all the functions of a **[love.physics joint](https://love2d.org/wiki/Joint)**._
- **Queries** : _Get all the colliders from an area._

## Demos
Every demo is self contained, open them as if they were normal Löve games.

- **Demo1** is focused on **Collision classes**
- **Demo2** is focused on **Collision responses**

_Minimal exemple :_
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

# API

## World

```lua
Physics = require("path/to/physics")
```
_Initialize the library._

---
```lua 
World = Physics(xg, yg, sleep)
```
- `xg(number)`: _horizontal gravity._ 
- `yg(number)`: _vertical gravity._
- `sleep(boolean)`: _whether the bodies in this world are allowed to sleep._

**return :** `World`

_Create a new world, same as **love.physics.newWorld(xg, yg, sleep)**._

---
```lua
World:draw()
```

_Draw **Colliders**, **Joints** and **Queries**, useful for debug and fast prototyping._

---
```lua 
World:update(dt)
```
- `dt(number)`: _delta time._

_Update the world, put this into the `love.update(dt)` function._

---
```lua 
World:setEnter(function(shape1, shape2, contact) end)
World:setExit(function(shape1, shape2, contact) end)
World:setPresolve(function(shape1, shape2, contact) end)
World:setPostsolve(function(shape1, shape2, contact, ...) end)
```
  - `shape1`: the **_love.physics shape_** of the first **_Collider_**.
  - `shape2`: the **_love.physics shape_** of the second **_Collider_**.
  - `contact`: [Contact](https://love2d.org/wiki/Contact)
  - `...`: **_normal_impulse1_**, **_tangent_impulse1_**, **_normal_impulse2_**, **_tangent_impulse2_** (see the [Notes](https://love2d.org/wiki/World:setCallbacks) part).

**return :** `self`

_Global callback functions that are going to be called every time a collider touch (**enter**) stop touching (**exit**) is touching before the physics is applied (**presolve**), after the physics is applied (**postsolve**)._

**shape1 and shape2 are shapes from this library, NOT love.physics shapes.**

---
```lua 
World:addClass(name, ignore)
```
- `name(string)`: _name of the new class_
- `ignore(table)`: _{"my_class1", "my_class2", "my_class3"}_

**return :** `self`

_Add a class and what other classes it ignore, it's a wrapper around box2d categories / masks as explained [here](https://love2d.org/forums/viewtopic.php?f=4&t=75441) ._

*Exemple:*
```lua
world:addClass("my_class1", {"my_class1","my_class2"})
world:addClass("my_class2")
world:addClass("my_class3", {"my_class2"})
-- colliders with the class **my_class1** are only going to collide with colliders with class **my_class3**.*
-- colliders with the class **my_class2** are only going to collide with colliders with class **my_class2**.*
-- colliders with the class **my_class3** are going to collide with colliders with class **my_class1** and **my_class3**.*
```
_See  the **Demo1** for a more complete exemple._

---
```lua
World:addCollider(collider_type, ...)

World:addRectangle(x, y, width, height, angle, type)
World:addCircle(x, y, radius, type)
World:addPolygon(x, y, vertices, type)
World:addLine(x1, y1, x2, y2, type)
World:addChain(loop, vertices, type)
```
**return :** [Collider](#colliders)

_Add a **Collider** to the World.  
You can execute all of the **love.physics [fixture]()/[body]()/[shape]()** functions on it.
Every Collider is initialized with a `"main"` **Shape**._
_Default `type` for **rectangle**, **circle**, **polygon** is `"dynamic"` and **line**, **chain** is `"static"`._

*`addRectangle()`, ect... are shortcuts to `World:addCollider("rectangle")`.*

## Joints
```lua
World:addJoint(joint_type, collider1, collider2, ...)
```
- `joint_type(string)`

**return :** `Joint`

*Add a joint that contains all the love.physics [Joint](https://love2d.org/wiki/Joint) functions.*

*Joint types are : **_distance_**, **_friction_**, **_gear_**, **_motor_**, **_mouse_**, **_prismatic_**, **_pulley_**, **_revolute_**, **_rope_**, **_weld_**, **_wheel_**   

## Queries
```lua
World:queryRectangle(x,y, width, height, class)
World:queryCircle(x, y, radius, class)
World:queryPolygon(verticles, class)
World:queryLine(x1, y1, x2, y2, class)
```
**return :** `{Collider1, Collider2, Collider3, ...}`

## Colliders
```lua 
Collider:setEnter(function(shape1, shape2, contact, inverted) end)
Collider:setExit(function(shape1, shape2, contact, inverted) end)
Collider:setPresolve(function(shape1, shape2, contact, inverted) end)
Collider:setPostsolve(function(shape1, shape2, contact, inverted, ...) end)
```
  - `shape1(Shape)`: the **_love.physics shape_** of the current **_Collider_**.
  - `shape2(Shape)`: the **_love.physics shape_** of the other **_Collider_**.
  - `contact(Contact)`: [Contact](https://love2d.org/wiki/Contact)
  - `inverted(boolean)`: if **_true_** then the first **_love.physics shape_** returned by [Contact:getNormal()](https://love2d.org/wiki/Contact:getNormal) and [Contact:getPositions()](https://love2d.org/wiki/Contact:getPositions) correspond to **_shape2_** and the second to **_shape1_**.
  - `...`: **_normal_impulse1_**, **_tangent_impulse1_**, **_normal_impulse2_**, **_tangent_impulse2_** (see the [Notes](https://love2d.org/wiki/World:setCallbacks) part).
  
  
**return :** `self`

 ---
```lua 
Collider:setClass(class_name)
```
-	`class_name(string)`

**return :** `self`

_Set a class to the Collider, the class need to be previously added to the World via `World:addClass(class_name)`._

---
```lua 
Collider:addShape(shape_tag, shape_type, ...)

Collider:addShape(shape_tag, "rectangle", x, y, w, h, angle)
Collider:addShape(shape_tag, "circle", x, y, radius)
Collider:addShape(shape_tag, "polygon", vertices)
Collider:addShape(shape_tag, "line", x1, y1, x2, y2)
Collider:addShape(shape_tag, "chain", loop, vertices)
```
**return :** `Shape`

---
```lua 
Collider:setData(data)
```
- `data(table)`

**return :** `self`

_Set custom data to a Collider_.

---
```lua 
Collider:setTag(tag)
```
- `tag(string)`

**return :** `self`

 _Set a custom tag to a Collider_.
 
---
```lua 
Collider:getClass()
```
**return :** `class(string)`

---
```lua 
Collider:getData()
```
**return :** `data(table)`

---
```lua 
Collider:getTag()
```
**return :** `tag(string)`

---
```lua 
Collider:getPShape(shape_tag)
```
**return :** `Shape` or `nil` if Shape doesn't exist in Collider.

---
```lua 
Collider:setAlpha(alpha)
```
- `alpha(number)`: _alpha value._

**return :** `self`

_Set alpha value for the Collider and every Shapes in it._

---
```lua 
Collider:setColor(r,g,b,a)
```
- `r(number)`: _red color._
- `g(number)`: _green color._
- `b(number)`: _blue color._
- `[a(number)]`: _alpha value._

**return :** `self`

_Set color for the Collider and every Shapes in it._

---
```lua 
Collider:setDrawMode(mode)
```
- `mode(string)`: _**"line"** or **"fill"**._

**return :** `self`

_Set draw mode for the Collider and every Shapes in it._

---
```lua
Collider:removeShape(shape_tag)
```

_Delete a Shape from the Collider._

## Shapes
```lua 
Shape:setEnter(function(shape1, shape2, contact, inverted) end)
Shape:setExit(function(shape1, shape2, contact, inverted) end)
Shape:setPresolve(function(shape1, shape2, contact, inverted) end)
Shape:setPostsolve(function(shape1, shape2, contact, inverted, ...) end)
```
  - `shape1(Shape)`: the **_love.physics shape_** of the current **_Collider_**
  - `shape2(Shape)`: the **_love.physics shape_** of the other **_Collider_**
  - `contact(Contact)`: [Contact](https://love2d.org/wiki/Contact)
  - `inverted(boolean)`: if **_true_** then the first **_love.physics shape_** returned by [Contact:getNormal()](https://love2d.org/wiki/Contact:getNormal) and [Contact:getPositions()](https://love2d.org/wiki/Contact:getPositions) correspond to **_shape2_** and the second to **_shape_**.
  - `...`: **_normal_impulse1_**, **_tangent_impulse1_**, **_normal_impulse2_**, **_tangent_impulse2_** (see the [Notes](https://love2d.org/wiki/World:setCallbacks) part).
 
**return :** `self`

---
```lua 
Shape:setAlpha(alpha)
```
- `alpha(number)`: _alpha value._

**return :** `self`

---
```lua 
Shape:setColor(r,g,b,a)
```
- `r(number)`: _red color._
- `g(number)`: _green color._
- `b(number)`: _blue color._
- `[a(number)]`: _alpha value._

**return :** `self`

---
```lua 
Shape:setDrawMode(mode)
```
- `mode(string)`: _**"line"** or **"fill"**._

**return :** `self`

---
```lua 
Shape:getCollider()
```
**return :** `Collider`

*Get the Collider containing the Shape.*

---
```lua 
Shape:getClass()
```
**return :** `class(string)`

*Get the class of the Collider containing the Shape.*



# Gotcha
These functions are used internaly, **DON'T USE THEM**:
  - `setUserData()`
  - `getUserData()`
  
There functions have a similar name, use them from **._fixture**, **._shape**, **._body** :
  - `isDestroyed()`
  - `testPoint()`
  - `getType()`
  - `raycast()`
  - `destroy()`
  - `release()`
  - `type()`
  - `typeOf()`
