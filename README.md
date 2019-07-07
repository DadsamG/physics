# LOVE_PHYSICS

## What is it ?
**physics.lua** is a **LÖVE** framework library that wrap the **love.physics** module to make it easier to use.
It's a complete rewrite of the **[Windfield](https://github.com/adnzzzzZ/windfield)** library 

**Why use it instead of Windfield ?**
- Some new features !
- Windfield is no longer maintened
- Less LOC, no dependencies
- I've found some bugs in Windfield (mainly collision callbacks)

**Why snake_case ?**
- I currently use snake_case in the library for convenience because I code in it, gonna switch to camelCase soon...

**XXX don't work, I want XXX feature**
- I'm open to suggestions, contact me here or on twitter (@4v0v_).

## Basics
```lua World:new(xg, yg, sleep) ```

=>Create a new world

```lua World:draw() ```

=>Draw colliders & joints, useful for debug

```lua World:set_enter(fn) ```

```lua World:set_exit(fn) ```

```lua World:set_presolve(fn) ```

```lua World:set_postsolve(fn) ```

=>Set a global collision callback function

```lua World:add_class(name, ignore) ```

=>Add a class and what other classes it ignore, it's a wrapper around box2d categories / masks as explained here:
https://love2d.org/forums/viewtopic.php?f=4&t=75441

```lua World:add_joint(joint_type, collider1, collider2, ...)```

=>Add a joint: https://love2d.org/wiki/Joint

```lua World:add_collider(collider_type, ...) ```

=>Add a collider to the world, a collider is an oject that contains a body, an a "main" shape. 
You can execute all fixtures/body/shapes functions on it.
