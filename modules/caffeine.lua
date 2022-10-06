---
--- 控制空闲时是否允许屏幕睡眠
---
-- require 'modules.shortcut'

local menuBarItem = nil
setCaffeine = function()
    if caffConfig ~= nil and caffConfig.caffeine == 'on' and menuBarItem == nil then
        -- print("设置状态栏")
        hs.alert.show("开启咖啡因", 0.5)
        menuBarItem = hs.menubar.new()
        menuBarItem:setTitle("")
        menuBarItem:setIcon("./icons/caffeine-on.pdf")
        hs.caffeinate.set("displayIdle", true)
    end
end

unsetCaffeine = function()
    hs.caffeinate.set("displayIdle", false)
    hs.alert.show("关闭咖啡因", 0.5)
    menuBarItem:delete()
end

-- setCaffeine = function()
--     if caffConfig ~= nil and caffConfig.caffeine == 'on' and menuBarItem == nil then
--         print("设置状态栏")
--         menuBarItem = hs.menubar.new()
--         menuBarItem:setTitle("")
--         menuBarItem:setIcon("./icons/caffeine-on.pdf")
--         hs.caffeinate.set("displayIdle", true)
--     else
--     end
-- end

-- resetCaffeineMeun = function()
--     if (caffConfig ~= nil and caffConfig.caffeine == 'on' and menuBarItem:isInMenuBar() == false) then
--         -- print("重置状态栏")
--         menuBarItem:delete()
--         menuBarItem = hs.menubar.new()
--         menuBarItem:setTitle("")
--         menuBarItem:setIcon("./icons/caffeine-on.pdf")
--         --hs.caffeinate.set("displayIdle", true)
--     end
-- end

-- local function initData()
--     setCaffeine()
--     --监听咖啡因的状态,判断是否要重置
--     hs.timer.doEvery(1, resetCaffeineMeun)
-- end

-- hs.hotkey.bind(caffConfig.hotkey[1], caffConfig.hotkey[2], function()
--     -- 初始化
--     initData()
-- end)
