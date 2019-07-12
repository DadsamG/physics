# PHYSICS

## What is it ?
**physics.lua** is a **LÖVE** framework library that wrap the **[love.physics](https://love2d.org/wiki/love.physics)** module to make it easier to use. It's a complete rewrite of the **[Windfield](https://github.com/adnzzzzZ/windfield)** library. Before using it I recommand checking out how the **love.physics** module works. 

**Why use it instead of Windfield ?**
- Some new features !
- Windfield is no longer maintened
- Less LOC, no dependencies
- I've found some bugs in Windfield (mainly collision callbacks)

**Why snake_case ?**
- I currently use snake_case in the library for convenience because I code in it, gonna switch to camelCase soon...

**XXX don't work, I want XXX feature**
- I'm open to suggestions, contact me here or on twitter ([@4v0v_](https://twitter.com/4v0v_/)).

## Basics

There are the concepts of this library :
- **World** : One world equals one physic simulation, it's the hightest level container.
- **Colliders** : A collider is an object residing in the world that react to the world physic and other colliders.
- **Classes** : A collider can have ONE class, the class tell what other class the collider can collide with.
- **Shapes** : A collider can have multiples shapes, two triangles and one rectangle for exemple.
- **Collision callbacks** : 
  - **enter** : what to do when a collider/shape begin touching another one.
  - **exit** : what to do when a collider/shape stop touching another one.
  - **presolve** : what to do each frame a collider/shape is touching another one before the physics is applied.
  - **postsolve** : what to do each frame a collider/shape is touching another one after the physics is applied.
- **Joints** : Attach 2 colliders together in different ways
- **Queries** : Get all the colliders from a certain area


## API

- **World:new([xg, yg, sleep])**:
  - **xg** = number
  - **yg** = number
  - **sleep** = boolean
Create a new world, same as **love.physics.newWorld**.

- **World:draw()**:
Draw colliders, joints and queries, useful for debug and fast prototyping.

- **World:set_enter(function(shape1, shape2, contact) end)**:

Global callback function that is going to be called every time a collider touch another.

**/!\** **shape1** and **shape2** are shapes from this library, **NOT** love.physics shapes **/!\**

- **World:set_exit(function(shape1, shape2, contact) end)**:

Global callback function that is going to be called every time a collider stop touching another.

**/!\** **shape1** and **shape2** are shapes from this library, **NOT** love.physics shapes **/!\**

- **World:set_presolve(function(shape1, shape2, contact) end)**:

Global callback function that is going to be called every time a collider is touching another, before the physics is applied.

**/!\** **shape1** and **shape2** are shapes from this library, **NOT** love.physics shapes **/!\**

- **World:set_postsolve(function(shape1, shape2, contact) end)**:

Global callback function that is going to be called every time a collider is touching another, after the physics is applied.

**/!\** **shape1** and **shape2** are shapes from this library, **NOT** love.physics shapes **/!\**


- **World:add_class(name, ignore)**:
  - name = string
  - ignore = table

Add a class and what other classes it ignore, it's a wrapper around box2d categories / masks as explained here:
https://love2d.org/forums/viewtopic.php?f=4&t=75441
```lua
world:add_class("my_class1", {"my_class1","my_class2")
world:add_class("my_class2")
world:add_class("my_class3", {"my_class2"})
```
For exemple here:
- colliders with the class **my_class1** are only going to collide with colliders with class **my_class3**.
- colliders with the class **my_class2** are only going to collide with colliders with class **my_class2**.
- colliders with the class **my_class3** are going to collide with colliders with class **my_class1** and **my_class3**.



```lua World:add_joint(joint_type, collider1, collider2, ...)```

=>Add a joint: https://love2d.org/wiki/Joint

```lua World:add_collider(collider_type, ...) ```

=>Add a collider to the world, a collider is an oject that contains a body, an a "main" shape. 
You can execute all fixtures/body/shapes functions on it.
