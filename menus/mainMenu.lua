local ret = {};

local ctrls = require('menus/controls');

ret.name = "main";

ret.font = love.graphics.newFont(48);

ret.newGame = ctrls.button({x = 300, y = 220}, {x = 500, y = 260}, "New Game", 24);

ret.levelEdit = ctrls.button({x = 300, y = 270}, {x = 500, y = 310}, "Level Editor", 24);

ret.settings = ctrls.button({x = 300, y = 320}, {x = 500, y = 360}, "Settings", 24);

ret.quit = ctrls.button({x = 300, y = 370}, {x = 500, y = 410}, "Quit", 24);

ret.title = {text = love.graphics.newText(ret.font, "Trail Blazers"), 
             angle = 0, angleCount = 0,
             scale = 0.5, scaleCount = 0};



ret.update = function(self)
    
    self.title.angleCount = (self.title.angleCount + 0.06) % (math.pi * 2);
    self.title.angle = math.sin(self.title.angleCount) * 0.35;

    self.title.scaleCount= (self.title.scaleCount + 0.04) % (math.pi*2);
    self.title.scale = math.sin(self.title.scaleCount) / 4 + 1;

    self.newGame:update();
    self.levelEdit:update();
    self.settings:update();
    self.quit:update();
end



ret.draw = function(self)
    love.graphics.draw(self.title.text, 400, 90, self.title.angle, 
                       self.title.scale, self.title.scale,
                       self.title.text:getWidth()/2, self.title.text:getHeight()/2);

    self.newGame:draw();
    self.levelEdit:draw();
    self.settings:draw();
    self.quit:draw();
end

return ret;