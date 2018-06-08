local wallFactory = {};

function wallFactory.new(str, player) 
    local util = require("utils");
    
    local ret = {};

    local strs = util.str.explode(str, ",");

    ret.player = player;

    ret.type = string.gsub(strs[1], "\r\n", "");
    
    ret.x1 = tonumber(strs[2]);
    ret.y1 = tonumber(strs[3]);

    ret.x2 = tonumber(strs[4]);
    ret.y2 = tonumber(strs[5]);

    ret.update = wallFactory.update;
    ret.draw = wallFactory.draw;
    ret.hitDetection = wallFactory.hitDetection;
    ret.rotateTranslate = wallFactory.rotateTranslate;

    ret.drawP = {x = 0, y = 0};

    return ret;
end

function wallFactory:update(dt) 
    if self.type == "normal" then 
        self:hitDetection(dt);
    end

    if self.type == "kill" then
        --if self:generalHit() then 
            
        --end
    end
end

function checkTri(x,y,p1,p2,p3)
    local b1,b2,b3;

    b1 = sign(x,y,p1.x,p1.y,p2.x,p2.y) < 0;
    b2 = sign(x,y,p2.x,p2.y,p3.x,p3.y) < 0;
    b3 = sign(x,y,p3.x,p3.y,p1.x,p1.y) < 0;

    return (b1 == b2) and (b2 == b3);
end

function sign(x1,y1,x2,y2,x3,y3)
    return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
end

function wallFactory.rotateTranslate(player, angle, xyClosest)
    local ax = (xyClosest.x);
    local ay = (xyClosest.y);
    
    local dx = (ax * math.cos(-player.angle)) - (ay * math.sin(-player.angle));
    local x = player.x + dx;
    
    local dy = (ay * math.cos(-player.angle)) + (ax * math.sin(-player.angle));
    local y = player.y + dy;

    return {x = x, y = y};
end

function wallFactory:generalHit()


end

function wallFactory:hitDetection(dt)
    --colision
    local tl = {x = self.x1, y = self.y1};
    local tr = {x = self.x2, y = self.y1};
    local bl = {x = self.x1, y = self.y2};
    local br = {x = self.x2, y = self.y2};
    local cent = {x = self.x1 + (self.x2-self.x1)/2, y = self.y1 + (self.y2-self.y1) / 2}
   
    local bounceScale = 0.5;

    local angle = math.atan2(self.player.y - cent.y, self.player.x - cent.x);
    
    local xyClosest = self.player:getEdge(angle + math.pi);

    local closest = self.rotateTranslate(self.player, angle, xyClosest);

    local x = closest.x;
    local y = closest.y;

    self.drawP = {x = x, y = y};

    local pushAwayVel = 0;
    
    --top tri
    local xy = self.player:getEdge(math.pi * 0.5);
    if checkTri(self.player.x, self.player.y + xy:total(), tl, tr, cent) or
        checkTri(x, y, tl, tr, cent) then
        if self.player.vel.y >= 0 then self.player.vel.y = -self.player.vel.y * (1 + bounceScale); end
        if self.player.vel.y < -1 then self.player.vel.y = -(settings.gravity * dt); end
        self.player.y = self.y1 - xy:total();
        return true;
    end
    
    --right tri
    xy = self.player:getEdge(math.pi);
    if checkTri(self.player.x - xy:total(), self.player.y, tr, br, cent) or
        checkTri(x, y, tr, br, cent) then
        self.player.vel.x = -self.player.vel.x * bounceScale;
        self.player.vel.x = self.player.vel.x - pushAwayVel;
        self.player.x = self.x2 + xy:total();
        return true;
    end
    --bottom tri
    xy = self.player:getEdge(math.pi * 1.5);
    if checkTri(self.player.x, self.player.y - xy:total(), bl, br, cent) or
        checkTri(x, y, bl, br, cent) then
        self.player.vel.y = self.player.vel.y * 0.2;
        self.player.y = self.y2 + xy:total();
        return true;
    end
    --left tri
    xy = self.player:getEdge(0);
    if checkTri(self.player.x + xy:total(), self.player.y, tl, bl, cent) or
        checkTri(x, y, tl, bl, cent) then
        self.player.vel.x = -self.player.vel.x * bounceScale;
        self.player.vel.x = self.player.vel.x + pushAwayVel;
        self.player.x = self.x1 - xy:total();
        return true;
    end
end
    
function wallFactory:killDetection()

end

function wallFactory:draw() 
    local lg = love.graphics;
   
    local style = "fill";
    
    if self.type == "normal" then lg.setColor(1, 1, 1); end
    if self.type == "kill" then lg.setColor(1, 0, 0); end
    if self.type == "goal" then lg.setColor(0, 1, 0); style = "line"; end
    
    lg.polygon(style, self.x1, self.y1,
    self.x2, self.y1, 
    self.x2, self.y2,
    self.x1, self.y2);
    
    if dbg.toggle then
        lg.setColor(1,1,0);
        lg.circle("fill", self.drawP.x, self.drawP.y, 3);
    end
end

return wallFactory;