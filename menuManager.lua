local ret = {}
    
    ret.menus = {
        main = require('menus/mainMenu'),
        --settings = require('menus/settings');
        
        --pause = require('menus/pause');

        --levelSelect = require('menus/levels');

        --levelComplete = require('menus/complete');
    };

    --ret.menus.main.newGame.callback = {func = function(args) ret.openNew(end,}

    ret.menuHistory = {
        index = 0,
        items = {}
    };

    ret.openNew = function (self, menuName)
        table.insert(self.menuHistory.items, menuName);
        self.menuHistory.index = self.menuHistory.index + 1;
    end

    ret.back = function (self)
        table.remove(self.menuHistory.items);
        self.menuHistory.index = self.menuHistory.index - 1;
    end

    ret.reset = function(self)   
        self.menuHistory = {
            index = 0;
            items = {};
        }
    end

    ret.update = function(self)
        local currentMenu = self.menuHistory.items[self.menuHistory.index];
        
        for key, val in pairs(self.menus) do
            if currentMenu == val.name then val:update(); end
        end
    end

    ret.draw = function (self)
        local currentMenu = self.menuHistory.items[self.menuHistory.index];

        for key, val in pairs(self.menus) do
            if currentMenu == val.name then val:draw(); end
        end
    end

return ret;