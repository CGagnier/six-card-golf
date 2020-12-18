function love.conf(t)
    t.version = "11.3"  
    t.window.title = "Six Card Golf" 
    t.window.width = 400
    t.window.height = 240
    t.window.resizable = true

    t.modules.audio = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.touch = false
    t.modules.timer = false
    t.modules.mouse = false
    t.modules.video = false
    t.modules.system = false
    t.modules.data = false
    t.modules.thread = false
end