-- 窗口快捷调整大小和布局

hs.loadSpoon("ModalMgr")
hs.loadSpoon("WinMan")
hs.loadSpoon("TilingWindowManagerMod")
-- require("configs.shortcuts")
require("configs.windowConfig")
require("configs.winmanShortcuts")
require("modules.window")
-- require 'modules.application'

local TWM = spoon.TilingWindowManagerMod
TWM:setLogLevel("debug")
TWM:start({
        menubar = true,
        dynamic = winman_dynamicAdjustWindowLayout,
        layouts = {
            spoon.TilingWindowManagerMod.layouts.fullscreen,
            spoon.TilingWindowManagerMod.layouts.tall,
            spoon.TilingWindowManagerMod.layouts.talltwo,
            spoon.TilingWindowManagerMod.layouts.wide,
            spoon.TilingWindowManagerMod.layouts.floating,
        },
        displayLayout = true,
        floatApps = {}
    })
CurrentLayoutMode = nil


-- 定义窗口管理模式快捷键
if spoon.WinMan then
    local handleMode = function()
        if winman_mode ~= "persistent" then
            spoon.ModalMgr:deactivate({ "windowM" })
        end
    end

    local function handleTileMode(mode)
        local tilingConfig = TWM.tilingConfigCurrentSpace(true)
        -- TWM.tilingStrategy[TWM.layouts.tall].tile(tilingConfig)
        TWM.tilingStrategy[TWM.layouts[mode]].tile(tilingConfig)
        CurrentLayoutMode = mode
    end

    local function handleWindowFlexOrResize(type, indexOrRatio)
        local tilingConfig = TWM.tilingConfigCurrentSpace()
        if type == "resizeWidth" then
            tilingConfig.mainRatio = tilingConfig.mainRatio + indexOrRatio
        else
            tilingConfig.mainNumberWindows = tilingConfig.mainNumberWindows + indexOrRatio
        end
        tilingConfig.layout = CurrentLayoutMode
        TWM.tilingStrategy[TWM.layouts[CurrentLayoutMode]].tile(tilingConfig)
    end

    local function handleWindowFocusOrSwap(type, index)

        local windows = TWM.tilingConfigCurrentSpace().windows
        if #windows > 1 then
            local i = hs.fnutils.indexOf(windows, hs.window.focusedWindow())
            if i and type == 'focus' then
                local j = (i - 1 + index) % #windows + 1
                windows[j]:focus():raise()
            elseif i and type == 'swap' then
                if index ~= 0 then
                    local j = (i - 1 + index) % #windows + 1
                    windows[i], windows[j] = windows[j], windows[i]
                else
                    windows[i], windows[1] = windows[1], windows[i]
                end
                local tilingConfig = TWM.tilingConfigCurrentSpace(windows)
                tilingConfig.layout = CurrentLayoutMode
                TWM.tilingStrategy[TWM.layouts[CurrentLayoutMode]].tile(tilingConfig)
            end
        end
    end

    spoon.ModalMgr:new("windowM")
    local cmodal = spoon.ModalMgr.modal_list["windowM"]
    cmodal:bind("", "escape", "退出 ", function()
        spoon.ModalMgr:deactivate({ "windowM" })
    end)
    cmodal:bind("", "Q", "退出", function()
        spoon.ModalMgr:deactivate({ "windowM" })
    end)
    cmodal:bind("", "tab", "键位提示", function()
        spoon.ModalMgr:toggleCheatsheet()
    end)

    -- # {{{ 多 App 窗口多种布局轮切
    -- 优先水平方向均分模式
    -- cmodal:bind("", "t", "tallMode", function()
    --     handleTileMode('tall')
    --     handleMode()
    -- end)
    -- -- 双栏模式
    -- cmodal:bind("", "m", "talltwoMode", function()
    --     handleTileMode('talltwo')
    --     handleMode()
    -- end)
    -- -- 优先垂直方向均分模式
    -- cmodal:bind("", ",", "wideMode", function()
    --     handleTileMode('wide')
    --     handleMode()
    -- end)
    -- -- 全屏(最大化)模式
    -- cmodal:bind("", ";", "fullscreenMode", function()
    --     handleTileMode('fullscreen')
    --     handleMode()
    -- end)
    -- 布局分割线右移伸展
    -- cmodal:bind("", "E", "incMainRatio", function()
    --     handleWindowFlexOrResize('windowRatio', 0.05)
    --     handleMode()
    -- end)
    -- -- 布局分割线左移收缩
    -- cmodal:bind("", "S", "decMainRatio", function()
    --     handleWindowFlexOrResize('windowRatio', -0.05)
    --     handleMode()
    -- end)
    -- -- cmodal:bind({"Ctrl"}, "E", "incMainWindows", function()
    -- -- 当前聚焦窗口高度折半
    -- cmodal:bind("", "R", "incMainWindows", function()
    --     handleWindowFlexOrResize('windowRotate', 1)
    --     handleMode()
    -- end)
    -- -- cmodal:bind({"Ctrl"}, "S", "decMainWindows", function()
    -- -- 当前聚焦窗口高度增倍
    -- cmodal:bind({"Ctrl"}, "R", "decMainWindows", function()
    --     handleWindowFlexOrResize('windowRotate', -1)
    --     handleMode()
    -- end)
    -- 聚焦下一个窗口
    -- cmodal:bind({"Ctrl"}, "K", "focusNext", function()
    --     handleWindowFocusOrSwap('focus', 1)
    --     handleMode()
    -- end)
    -- -- 聚焦上一个窗口
    -- cmodal:bind({"Ctrl"}, "J", "focusPrev", function()
    --     handleWindowFocusOrSwap('focus', -1)
    --     handleMode()
    -- end)
    -- -- 与上一个窗口交互位置
    -- cmodal:bind({"Ctrl"}, "L", "swapPrev", function()
    --     handleWindowFocusOrSwap('swap', 1)
    --     handleMode()
    -- end)
    -- -- 与下一个窗口交互位置
    -- cmodal:bind({"Ctrl"}, "H", "swapNext", function()
    --     handleWindowFocusOrSwap('swap', -1)
    --     handleMode()
    -- end)
    -- 与第一个窗口交互位置
    -- cmodal:bind({"Ctrl"}, "I", "swapFirst", function()
    --     handleWindowFocusOrSwap('swap', 0)
    --     handleMode()
    -- end)
    -- 显示模式 
    -- cmodal:bind({"Ctrl"}, "D", "displayMode", function()
    --     local curModeName = '当前模式: ' .. CurrentLayoutMode
    --     hs.alert.show(curModeName)
    --     handleMode()
    -- end)

    -- # 多 App 窗口多种布局轮切 }}}


    -- {{{ 窗口管理之 传统模式
    hs.fnutils.each(winman_keys, function(item)
        if item.tag == "origin" then
            local wfn = item.func
            if wfn == "moveAndResize" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    if item.location ~= "shrink" and item.location ~= "expand" then
                        spoon.WinMan:moveAndResize(item.location)
                    else
                        spoon.WinMan:moveAndResize(item.location)
                        spoon.WinMan:moveAndResize(item.location)
                    end
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "stepResize" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:stepResize(item.direction)
                    spoon.WinMan:stepResize(item.direction)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "wMoveToScreen" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:cMoveToScreen(item.location)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "moveToSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:moveToSpace(item.direction, item.followWindow)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "moveAndFocusToSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:moveToSpace(item.direction)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "killSameAppAllWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    kill_same_application()
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "closeSameAppOtherWindows" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    close_same_application_other_windows()
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "gridWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.GRID)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "flattenWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "rotateLayout" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL_R)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "flattenWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "gridWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.GRID)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            elseif wfn == "rotateLayoutWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL_R)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            else
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:undo()
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleMode()
                end)
            end
        end

        if item.tag == "tile" then
            if item.mode then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    handleTileMode(item.mode)
                    handleMode()
                end)
            end

            if item.action then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    if item.action == 'showMode' then
                        -- if not CurrentLayoutMode then CurrentLayoutMode = '' end
                        local curModeName = '当前模式: ' .. (CurrentLayoutMode or '未开始 Tile 模式')
                        hs.alert.show(curModeName)
                        handleMode()
                    else
                        local directionMapVal = {next = 1, prev = -1, first=0}
                        handleWindowFocusOrSwap(item.action, directionMapVal[item.direction])
                        handleMode()
                    end
                end)
            end

            if item.sizeVal then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    handleWindowFlexOrResize(item.action, item.sizeVal)
                    -- handleWindowFlexOrResize('windowRatio', -0.05)
                    handleMode()
                end)
            end
        end
    end)

    -- 定义窗口管理模式快捷键
    local winman_toggle = winman_toggle or { "alt", "R" }
    if string.len(winman_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(winman_toggle[1], winman_toggle[2], "进入窗口管理传统模式", function()
            local message = require("modules.status-message")
            cmodal.statusMessage = message.new("WinMan Mode")
            cmodal.entered = function()
                cmodal.statusMessage:show()
            end

            cmodal.exited = function()
                cmodal.statusMessage:hide()
            end

            spoon.ModalMgr:deactivateAll()
            -- 显示状态指示器，方便查看所处模式
            spoon.ModalMgr:activate({ "windowM" }, "#B22222")
        end)
    end
    -- 窗口管理之 传统模式 }}}
end

-- 窗口管理之 Grid 轮切模式
if spoon.WinMan then
    local handleMode = function()
        if winman_mode ~= "persistent" then
            spoon.ModalMgr:deactivate({ "windowRGrid" })
        end
    end

    spoon.ModalMgr:new("windowRGrid")
    local cmodal = spoon.ModalMgr.modal_list["windowRGrid"]
    cmodal:bind("", "escape", "退出 ", function()
        spoon.ModalMgr:deactivate({ "windowRGrid" })
    end)
    cmodal:bind("", "Q", "退出", function()
        spoon.ModalMgr:deactivate({ "windowRGrid" })
    end)
    cmodal:bind("", "tab", "键位提示", function()
        spoon.ModalMgr:toggleCheatsheet()
    end)

    hs.fnutils.each(winman_keys, function(item)
        if item.tag == "grid" then
            cmodal:bind(item.prefix, item.key, item.message, function()
                rotateWinGrid(item.mapGridGroup)
                handleMode()
            end)
        end
    end)

    -- 定义窗口管理模式快捷键
    local winGridMan_toggle = winGridMan_toggle or { "alt", "R" }
    if string.len(winGridMan_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(
            winGridMan_toggle[1],
            winGridMan_toggle[2],
            "进入窗口管理 Grid 轮切模式",
            function()
                local message = require("modules.status-message")
                cmodal.statusMessage = message.new("WinGridMan Mode")
                cmodal.entered = function()
                    cmodal.statusMessage:show()
                end

                cmodal.exited = function()
                    cmodal.statusMessage:hide()
                end

                spoon.ModalMgr:deactivateAll()
                -- 显示状态指示器，方便查看所处模式
                spoon.ModalMgr:activate({ "windowRGrid" }, "#C88888")
            end
        )
    end
end

spoon.ModalMgr.supervisor:enter()

--- App 窗口开启全局任意方式切换后自动调整布局, 有一定程度性会下降!

local Count = 0
local function execAppWindowAutoLayout()
    AppWindowAutoLayout()
    Count = Count + 1
    if #alwaysAdjustAppWindowLayoutData ~= 0 or Count > 1 then
        AppWindowAutoLayoutTimer:stop()
    end
end

if winman_dynamicAdjustWindowLayout then
    AppWindowAutoLayoutTimer = hs.timer.new(2, execAppWindowAutoLayout)
    AppWindowAutoLayoutTimer:start()
end


----------------------------------------------------------------
---- TilingWindowManager 独立配置如下
-- local Shyper = { "Ctrl", "Option", "Cmd" }
-- hs.loadSpoon("TilingWindowManager")
--     :setLogLevel("debug")
--     :bindHotkeys({
--         tile =           {Shyper, "t"},
--         incMainRatio =   {Shyper, "p"},
--         decMainRatio =   {Shyper, "o"},
--         incMainWindows = {Shyper, "i"},
--         decMainWindows = {Shyper, "u"},
--         focusPrev =      {Shyper, "k"},
--         focusNext =      {Shyper, "j"},
--         swapNext =       {Shyper, "l"},
--         swapPrev =       {Shyper, "h"},
--         toggleFirst =    {Shyper, "return"},
--         tall =           {Shyper, ","},
--         talltwo =        {Shyper, "m"},
--         fullscreen =     {Shyper, "."},
--         wide =           {Shyper, ";"},
--         display =        {Shyper, "d"},
--     })
--     :start({
--         menubar = true,
--         dynamic = false,
--         layouts = {
--             spoon.TilingWindowManager.layouts.fullscreen,
--             spoon.TilingWindowManager.layouts.tall,
--             spoon.TilingWindowManager.layouts.talltwo,
--             spoon.TilingWindowManager.layouts.wide,
--             spoon.TilingWindowManager.layouts.floating,
--         },
--         displayLayout = true,
--         floatApps = {
--             "com.apple.Finder",
--         }
--     })

-- hs.hotkey.bind(Shyper, 'y', 'stop' , function ()
--     hs.loadSpoon("TilingWindowManager"):toggleTWM({
--         menubar = true,
--         dynamic = false,
--         layouts = {
--             floating = "Floating",
--             fullscreen = "Fullscreen",
--             tall = "Tall",
--             wide = "Wide",
--             talltwo = "Tall Two Pane"
--         },
--         displayLayout = true,
--         floatApps = {
--             "com.apple.Finder",
--         }
--     })
-- end)







-- cmodal:bind('', 'A', '向左移动', function() spoon.WinMan:stepMove("left") end, nil, function() spoon.WinMan:stepMove("left") end)
-- cmodal:bind('', 'D', '向右移动', function() spoon.WinMan:stepMove("right") end, nil, function() spoon.WinMan:stepMove("right") end)
-- cmodal:bind('', 'W', '向上移动', function() spoon.WinMan:stepMove("up") end, nil, function() spoon.WinMan:stepMove("up") end)
-- cmodal:bind('', 'S', '向下移动', function() spoon.WinMan:stepMove("down") end, nil, function() spoon.WinMan:stepMove("down") end)

-- cmodal:bind('', 'H', '左半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfleft") end)
-- cmodal:bind('', 'L', '右半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfright") end)
-- cmodal:bind('', 'K', '上半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfup") end)
-- cmodal:bind('', 'J', '下半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfdown") end)

-- cmodal:bind('', 'Y', '屏幕左上角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerNW") end)
-- cmodal:bind('', 'O', '屏幕右上角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerNE") end)
-- cmodal:bind('', 'U', '屏幕左下角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerSW") end)
-- cmodal:bind('', 'I', '屏幕右下角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerSE") end)

-- cmodal:bind('', 'F', '全屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("fullscreen") end)
-- cmodal:bind('', 'C', '居中', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("center") end)
-- cmodal:bind('', 'G', '左三分之二屏居中分屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("centermost") end)
-- cmodal:bind('', 'Z', '展示显示', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("show") end)
-- cmodal:bind('', 'V', '编辑显示', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("shows") end)

-- cmodal:bind('', 'X', '二分之一居中分屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("center-2") end)

-- cmodal:bind('', '=', '窗口放大', function() spoon.WinMan:moveAndResize("expand") end, nil,
-- function() Spoon.WinMan:spoon.WinMan:moveAndResize("expand") end)
-- cmodal:bind('', '-', '窗口缩小', function() spoon.WinMan:moveAndResize("shrink") end, nil,
-- function() spoon.WinMan:moveAndResize("shrink") end)

-- cmodal:bind('ctrl', 'H', '向左收缩窗口', function() spoon.WinMan:stepResize("left") end, nil, function() spoon.WinMan:stepResize("left") end)
-- cmodal:bind('ctrl', 'L', '向右扩展窗口', function() spoon.WinMan:stepResize("right") end, nil, function() spoon.WinMan:stepResize("right") end)
-- cmodal:bind('ctrl', 'K', '向上收缩窗口', function() spoon.WinMan:stepResize("up") end, nil, function() spoon.WinMan:stepResize("up") end)
-- cmodal:bind('ctrl', 'J', '向下扩镇窗口', function() spoon.WinMan:stepResize("down") end, nil, function() spoon.WinMan:stepResize("down") end)

-- cmodal:bind('', 'left', '窗口移至左边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("left") end)
-- cmodal:bind('', 'right', '窗口移至右边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("right") end)
-- cmodal:bind('', 'up', '窗口移至上边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("up") end)
-- cmodal:bind('', 'down', '窗口移动下边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("down") end)
-- cmodal:bind('', 'space', '窗口移至下一个屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("next") end)
-- cmodal:bind('', 'B', '撤销最后一个窗口操作', function() spoon.WinMan:undo() end)
-- cmodal:bind('', 'R', '重做最后一个窗口操作', function() spoon.WinMan:redo() end)

-- cmodal:bind('', '[', '左三分之二屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("mostleft") end)
-- cmodal:bind('', ']', '右三分之二屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("mostright") end)
-- cmodal:bind('', ',', '左三分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("lesshalfleft") end)
-- cmodal:bind('', '.', '中分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("onethird") end)
-- cmodal:bind('', '/', '右三分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("lesshalfright") end)

-- cmodal:bind('', 't', '将光标移至所在窗口中心位置', function() spoon.WinMan:centerCursor() end)
