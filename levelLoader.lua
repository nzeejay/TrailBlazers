local levelFactory = {};

function levelFactory.new(str, player) 
    local wallFactory = require('wall');
    local util = require("utils");

    local ret = {};

    local strs = util.str.explode(str, ";");

    ret.walls = {};

    for key, value in pairs(strs) do
        if key == 1 then 
            playerStr = util.str.explode(strs[1], ",");
            player.x = tonumber(playerStr[2]);
            player.y = tonumber(playerStr[3]);
            goto continue;
        end
        if value ~= "" then
            ret.walls[key] = wallFactory.new(value, player);
        end
        ::continue::
    end

    ret.update = levelFactory.update;
    ret.draw = levelFactory.draw;

    return ret;
end

function levelFactory:update(dt) 
    for key, value in pairs(self.walls) do
        
        value:update(dt);
        
    end
end

function levelFactory:draw() 

    for key, value in pairs(self.walls) do
        value:draw();
    end

end

return levelFactory;