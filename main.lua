function love.load()
    settings = require('settings');
    dbg = require('debug');
    
    factories = {};

    factories.player = require('playerRocket');
    factories.level = require('levelLoader');

    start();
    love.window.setMode(800, 600, {vsync = true});

    currentLevel = 0;

end

function start()
    ents = {};
    level = {};

    file = love.filesystem.newFile("levels/level1.txt")
    file:open('r')
    local s = file:read()
    file:close()

    ents.player = factories.player.new(100, 100);

    level = factories.level.new(s, ents.player);

    
    local ctrls = require('menus/controls');

   menu = require('menuManager');
   --menu:openNew("main");
end

function love.update(dt)

    --ents.player:update(dt);
    menu:update();
    --level:update(dt);

    local kd = love.keyboard.isDown;

    if kd("w") then 
        menu:openNew("main");
    end

    if kd("s") then 
        menu:back();
    end

    udt = dt;

end

function love.draw()
    --ents.player:draw();
    menu:draw();
    --level:draw();
    --love.graphics.print("       " .. 1 / udt);
end

function kill() 

end

function goal()

end