---@diagnostic disable: lowercase-global
---
--- 控制空闲时是否允许屏幕睡眠
---
-- require 'configs.shortcuts'

toggleCaffeine = function()
    local c = hs.caffeinate
    if not c then return end
    if c.get('displayIdle') or c.get('systemIdle') or c.get('system') then
        if menuCaff then
            menuCaffRelease()
        else
            addMenuCaff()
            local type
            if c.get('displayIdle') then type = 'displayIdle' end
            if c.get('systemIdle') then type = 'systemIdle' end
            if c.get('system') then type = 'system' end
            hs.alert('Caffeine already on for '..type)
        end
    else
        acAndBatt = hs.battery.powerSource() == 'Battery Power'
        c.set('system', true, acAndBatt)
        hs.alert('Caffeinated '..(acAndBatt and '' or 'on AC Power'))
        addMenuCaff()
    end
end

function addMenuCaff()
    menuCaff = hs.menubar.new()
    menuCaff:setIcon("./icons/caffeine-on.pdf")
    menuCaff:setClickCallback(menuCaffRelease)
end

function menuCaffRelease()
    local c = hs.caffeinate
    if not c then return end
    if c.get('displayIdle') then
        c.set('displayIdle', false, true)
    end
    if c.get('systemIdle') then
        c.set('systemIdle', false, true)
    end
    if c.get('system') then
        c.set('system', false, true)
    end
    if menuCaff then
        menuCaff:setIcon("./icons/caffeine-off.pdf")

        -- menuCaff:delete()
        -- menuCaff = nil
    end
    hs.alert('Decaffeinated', 0.5)
end