# LOVE_PHYSICS

World:new(xg, yg, sleep)
=>Create a new world

World:draw()
=>Draw colliders & joints, useful for debug

World:set_enter(fn)
World:set_exit(fn)
World:set_presolve(fn)
World:set_postsolve(fn)
=>Set a global collision callback function

World:add_class(name, ignore)
=>Add a class and what other classes it ignore, it's a wrapper around box2d categories / masks as explained here:
https://love2d.org/forums/viewtopic.php?f=4&t=75441

World:add_joint(joint_type, collider1, collider2, ...)
=>Add a joint: https://love2d.org/wiki/Joint

World:add_collider(collider_type, ...)
=>Add a collider to the world, a collider is an oject that contains a body, an a "main" shape. 
You can execute all fixtures/body/shapes functions on it.
