local playerRocketFactory = {};

function playerRocketFactory.new(XStart, YStart, level)
    local ret = {};
    ret.level = level;

    ret.x = XStart;
    ret.y = YStart;
    ret.angle = math.pi;

    ret.w = 12;
    ret.h = 24;

    ret.clr = {r = 0.5, g = 0.5, b = 0.5};

    ret.vel = {x = 0, y = 0, angle = 0, momentum = 0,
                damp = function(self, damp, dt)
                    local dampen = 1 - (damp * dt);
                    
                    self.x = self.x * dampen;     
                    self.y = self.y * dampen;
                    self.angle = self.angle * dampen;
                    self.momentum = self.momentum * (1 - (8 * dt));
                end,
                update = function(self, angle, dt)
                    self.x = self.x + (math.sin(angle) * self.momentum * dt);
                    self.y = self.y + (math.cos(angle) * self.momentum * dt);
                end,
                avg = function(self)
                    return (self.x + self.y) / 2;
                end
            };

    ret.speed = 500;

    ret.smoke = love.graphics.newParticleSystem(love.graphics.newImage('img/rocketPuff.png'), 2048);
    ret.smoke:setParticleLifetime(1, 3);
	ret.smoke:setEmissionRate(0);
    ret.smoke:setEmissionArea("ellipse", 4, 4);
	ret.smoke:setLinearAcceleration(-10, 10, 5, 15)
    ret.smoke:setColors(255, 255, 255, 255, 255, 200, 125, 0)
    ret.smoke:setSizes(0.2, 0.2, 0.3, 0.5);
    ret.smoke:setSpread(10);

    ret.fire = love.graphics.newParticleSystem(love.graphics.newImage('img/rocketFire.png'), 2048);
    ret.fire:setParticleLifetime(0.1, 0.2);
	ret.fire:setEmissionRate(0);
    ret.fire:setEmissionArea("ellipse", 4, 4);
	ret.fire:setLinearAcceleration(-5, 5, 20, 35)
    ret.fire:setColors(255, 255, 255, 255, 255, 200, 125, 0)
    ret.fire:setSizes(0.5, 0.3, 0.3, 0.2);
    ret.fire:setSpread(10);

    ret.update = playerRocketFactory.update;
    ret.movement = playerRocketFactory.movement;
    ret.draw = playerRocketFactory.draw;
    ret.die = playerRocketFactory.die;
    ret.getEdge = playerRocketFactory.getEdge;
    ret.detectEdge = playerRocketFactory.detectEdge;

    return ret;
end

function playerRocketFactory:update(dt)
    --rocket trail
    self.smoke:update(dt);
    self.smoke:setPosition(self.x - (math.sin(self.angle) * self.h/1.2), 
                           self.y - (math.cos(self.angle) * self.h/1.2));
    self.smoke:setDirection(self.angle);

    self.fire:update(dt);
    self.fire:setPosition(self.x - (math.sin(self.angle) * self.h/1.2), 
                          self.y - (math.cos(self.angle) * self.h/1.2));
    self.fire:setDirection(self.angle);

    self:movement(dt);

    --add vel to object
    self.vel:update(self.angle, dt);
    self.x = self.x + self.vel.x;
    self.y = self.y + self.vel.y + (settings.gravity * dt);

    --damp vel
    self.vel:damp(0.8, dt);

    --angle
    self.angle = (self.angle + self.vel.angle * dt) % (2*math.pi);        

    self:detectEdge(dt);
end

function playerRocketFactory:draw() 
    local lg = love.graphics;

    local x = -self.w/2;
    local y = -self.h/2;

    lg.setColor(1, 1, 1);
    love.graphics.draw(self.smoke, 0, 0);
    love.graphics.draw(self.fire, 0, 0);

    lg.push();
    lg.translate(self.x, self.y);
    lg.rotate(-self.angle);

    --rocket nozzle
    lg.setColor(0.75, 0.75, 0.75);
    lg.polygon("fill", x, -self.h/1.4, 
    self.w/2, -self.h/1.4,
    0, 0);

    --body and nose cone
    lg.setColor(self.clr.r, self.clr.g, self.clr.b);
    lg.rectangle("fill", x, y, self.w, self.h);
    lg.polygon("fill", x, self.h/2, 
    self.w/2, self.h/2,
    0, self.h + 1);

    if dbg.toggle then
        lg.setColor(1, 0, 0);
        lg.circle("fill", self:getEdge(0).x, self:getEdge(0).y, 3);
        lg.setColor(0, 1, 0);
        lg.circle("fill", self:getEdge(math.pi * 0.5).x, self:getEdge(math.pi * 0.5).y, 3);
        lg.setColor(0, 0, 1);
        lg.circle("fill", self:getEdge(math.pi).x, self:getEdge(math.pi).y, 3);
        lg.setColor(1, 1, 1);
        lg.circle("fill", self:getEdge(math.pi * 1.5).x, self:getEdge(math.pi * 1.5).y, 3);
        
        lg.setColor(0, 0, 0);
        lg.circle("fill", 0, 0, 3);
    end
    lg.pop();

    lg.setColor(1,1,1);
    --lg.print("        " .. self.vel.momentum);
end

function playerRocketFactory:movement(dt)
    local kd = love.keyboard.isDown;
	if kd("a") then self.vel.angle = self.vel.angle + settings.rotateSpeed * dt end
	if kd("d") then self.vel.angle = self.vel.angle - settings.rotateSpeed * dt end    
    if kd("w") then 
        self.vel.momentum = self.speed * dt; 
        self.smoke:emit(1 * settings.quality);
        self.fire:emit(2 * settings.quality);
    end
end

function playerRocketFactory:getEdge(angle, overide)
    local temp = self.angle;

    if overide then self.angle = 0 end
    
    local xval = math.cos(self.angle + angle) * (self.w/2.2);
    local yval = math.sin(self.angle + angle) * (self.h/1.3) + 3;

    local ret = {x = xval, y = yval, 
    total = function(self)
        local ret = math.sqrt(self.x^2 + self.y^2);
        return ret;
    end,
    };

    self.angle = temp;

    return ret;
end

function playerRocketFactory:detectEdge(dt)
    local bounceScale = 0.7;

    --left
    local xy = self:getEdge(math.pi);
    if self.x - xy:total() < 0 then        
        self.vel.x = -self.vel.x * bounceScale;
        self.x = xy:total();
    end

    xy = self:getEdge(0);
    if self.x + xy:total() > love.graphics.getWidth() then
        self.vel.x = -self.vel.x * bounceScale;
        self.x = love.graphics.getWidth() - xy:total();
    end
    
    xy = self:getEdge(math.pi*1.5);
    if self.y - xy:total() < 0 then
        self.vel.y = self.vel.y * 0.2;
        self.y = xy:total();
    end

    xy = self:getEdge(math.pi*0.5);
    if self.y + xy:total() > love.graphics.getHeight() then
       if self.vel.y >= 0 then self.vel.y = -self.vel.y * bounceScale; end
       if self.vel.y < -1 then self.vel.y = -(settings.gravity * dt) end
       self.y = love.graphics.getHeight() - xy:total();        
    end
end

return playerRocketFactory;