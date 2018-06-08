local controlFactory = {};

function controlFactory.button(p1, p2, text, fontSize, callback)
    local ret = {};

    ret.p1 = p1;
    ret.p2 = p2;

    ret.dim = {w = p2.x-p1.x, h = p2.y - p1.y};

    ret.text = love.graphics.newText(love.graphics.newFont(fontSize), text);
    ret.clr = {r = 1, g = 1, b = 1};
    ret.style = "line";

    ret.callback = callback;
    
    ret.click = controlFactory.click;
    ret.mouseHover = controlFactory.mouseHover;
    ret.draw = controlFactory.draw;
    ret.update = controlFactory.update;

    ret.clickable = false;

    return ret;
end

function controlFactory:click()

    if self:mouseHover() then
        self.clr = {r = 0.5, g = 0.5, b = 0.5};
        self.style = "fill";
    
        if love.mouse.isDown(1) then
            self.callback.func(self.callback.args);
            self.clickable = false;
        else 
            self.clickable = true;
        end    
    else 
        self.clr = {r = 1, g = 1, b = 1};
        self.style = "line";
    end
end

function controlFactory:mouseHover() 
    local x = love.mouse.getX();
    local y = love.mouse.getY();

    if x > self.p1.x and x < self.p2.x and
       y > self.p1.y and y < self.p2.y then
        return true;
    end 

    return false;
end

function controlFactory:update()
    self:click();
end

function controlFactory:draw()

    love.graphics.setColor(self.clr.r, self.clr.g, self.clr.b);
    love.graphics.rectangle(self.style, self.p1.x, self.p1.y, self.dim.w, self.dim.h, 4);
    
    love.graphics.setColor(1,1,1);
    love.graphics.draw(self.text, 
                        self.p1.x + self.dim.w / 2, 
                        self.p1.y + self.dim.h / 2, 0, 1, 1,
                        self.text:getWidth() / 2, self.text:getHeight() / 2);

end

return controlFactory;