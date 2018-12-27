function love.run()
    local dt = 0
    local _INPUT = {current_state = {}, previous_state = {}}
    lg.setLineStyle("rough")
    lg.setDefaultFilter("nearest", "nearest")

    function pressed(key) return _INPUT.current_state[key] and not _INPUT.previous_state[key] end
    function released(key) return _INPUT.previous_state[key] and not _INPUT.current_state[key] end
    function down(key) return love.keyboard.isDown(key) end   

    return function()
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit"        then if not love.quit or not love.quit() then return a or 0 end end
            if name == "keypressed"  then _INPUT.current_state[a] = true  end
            if name == "keyreleased" then _INPUT.current_state[a] = false end
            love.handlers[name](a,b,c,d,e,f)
        end
        
        dt = love.timer.step()
        if dt > 0.2 then return end
        love.update(dt)
        for k,v in pairs(_INPUT.current_state) do _INPUT.previous_state[k] = v end 
        
        if lg.isActive() then lg.origin(); lg.clear(lg.getBackgroundColor()); love.draw(); lg.present() end
        love.timer.sleep(0.001)
    end
end