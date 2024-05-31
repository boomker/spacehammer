-- 窗口快捷调整大小和布局

hs.loadSpoon("WinMan")
hs.loadSpoon("Layouts")
hs.loadSpoon("ModalMgr")
require("modules.window")
require("modules.windowTimeLine")
require("modules.status-message")
require("configs.windowConfig")
require("configs.winmanShortcuts")

local TWM = hs.loadSpoon("TilingWindowManagerMod")
-- TWM:setLogLevel("debug")                     -- 可选开启 Tile 模式下 debug 日志
TWMObj = TWM:start({
    menubar = true,
    dynamic = winman_dynamicAdjustWindowLayout, -- 是否开启实时动态窗口布局调整, 默认关闭, 开启会有些许性能下降
    layouts = {
        spoon.TilingWindowManagerMod.layouts.floating, -- 每个Space 默认用floating 布局, 即不改变当前现状的布局
        spoon.TilingWindowManagerMod.layouts.fullscreen,
        spoon.TilingWindowManagerMod.layouts.tall,
        spoon.TilingWindowManagerMod.layouts.talltwo,
        spoon.TilingWindowManagerMod.layouts.wide,
    },
    displayLayout = true,
    floatApps = {},
    fullscreenRightApps = { "md.obsidian" }, -- 支持指定 App 窗口右半屏布局(全屏模式下)
})

local WGL = spoon.Layouts
-- WGL.logger.setLogLevel('debug')           -- 可选开启 Layout Spoon debug 日志
WGL:start()

-- 记录所有屏幕所有 Space 的布局, SpaceUID --> layoutName
WindowLayoutForSpaceStatus = {
    tmpWindowLayoutName = nil,
}

-- ==== 窗口管理传统/Tile模式 ==== --
if spoon.WinMan then
    -- SpaceUID 由 ScreenID_SpaceID 构成
    local getSpaceUID = function()
        local curScreenId = hs.screen.mainScreen():id()
        local curSpaceId = hs.spaces.focusedSpace()
        local curSpaceUid = string.format("%d_%d", curScreenId, curSpaceId)
        return curSpaceUid
    end

    -- 是否保持持久模式, 对不同退出操作做善后处理
    local handleWinManMode = function(toggle)
        if not toggle then
            return
        end
        -- toggle: "on" means to "persistent"
        if winman_mode == "persistent" and toggle == "on" then
            return
        end
        if winman_mode ~= "persistent" or toggle then
            if toggle == "off" then
                spoon.ModalMgr:deactivate({ "windowM" })
            end
            local tilingConfig = TWM.tilingConfigCurrentSpace(true)
            local wdsLayoutForCurSpace = tilingConfig.layout
            if toggle == "exitByManual" then
                WindowLayoutForSpaceStatus[getSpaceUID()] = WindowLayoutForSpaceStatus[getSpaceUID()]
                    or wdsLayoutForCurSpace
                WindowLayoutForSpaceStatus.tmpWindowLayoutName = nil
            elseif toggle == "switchAfterExit" then
                WindowLayoutForSpaceStatus[getSpaceUID()] = wdsLayoutForCurSpace
                WindowLayoutForSpaceStatus.tmpWindowLayoutName = nil
            elseif toggle == "exitByFloat" then
                local tmpLayoutName = WindowLayoutForSpaceStatus.tmpWindowLayoutName
                    or WindowLayoutForSpaceStatus[getSpaceUID()]
                WindowLayoutForSpaceStatus[getSpaceUID()] = tmpLayoutName
                WindowLayoutForSpaceStatus.tmpWindowLayoutName = nil
            end
            spoon.ModalMgr:deactivate({ "windowM" })
        else
            return
        end
    end

    -- 持久模式下, 当前 Space 所有窗口切换到目标布局
    local function handleTileWindowLayout(tgtLayout)
        local tilingConfig = TWM.tilingConfigCurrentSpace(true)
        tilingConfig.layout = TWM.layouts[tgtLayout]
        TWM.tilingStrategy[TWM.layouts[tgtLayout]].tile(tilingConfig)
        WindowLayoutForSpaceStatus[getSpaceUID()] = tilingConfig.layout
        WindowLayoutForSpaceStatus.tmpWindowLayoutName = tilingConfig.layout
    end

    -- 窗口调整之后动作
    local afterHandelForWindow = function(tilingConfig)
        if WindowLayoutForSpaceStatus.tmpWindowLayoutName then
            TWM.tilingStrategy[tilingConfig.layout].tile(tilingConfig)
        else
            -- local getSpaceUID() = hs.spaces.focusedSpace()
            local lastLayout = WindowLayoutForSpaceStatus[getSpaceUID()]
            if lastLayout then
                TWM.tilingStrategy[lastLayout].tile(tilingConfig)
            else
                local layout = tilingConfig.layout
                TWM.tilingStrategy[layout].tile(tilingConfig)
            end
        end
    end

    -- 调整窗口尺寸
    local function handleWindowFlexOrResize(type, sizeOrRatio)
        local tilingConfig = TWM.tilingConfigCurrentSpace()
        if type == "resizeWidth" then
            tilingConfig.mainRatio = tilingConfig.mainRatio + sizeOrRatio
        else
            tilingConfig.mainNumberWindows = tilingConfig.mainNumberWindows + sizeOrRatio
        end
        afterHandelForWindow(tilingConfig)
    end

    -- 移动焦点到其他窗口或交换两个窗口
    local function handleWindowFocusOrSwap(type, index)
        local windows = TWM.tilingConfigCurrentSpace().windows
        if #windows > 1 then
            local focusWdIdx = hs.fnutils.indexOf(windows, hs.window.focusedWindow())
            if focusWdIdx and type == "focus" then
                local wdIdx = (focusWdIdx - 1 + index) % #windows + 1
                windows[wdIdx]:focus():raise()
            elseif focusWdIdx and type == "swap" then
                if index ~= 0 then
                    local wdIdx = (focusWdIdx - 1 + index) % #windows + 1
                    windows[focusWdIdx], windows[wdIdx] = windows[wdIdx], windows[focusWdIdx]
                else
                    windows[focusWdIdx], windows[1] = windows[1], windows[focusWdIdx]
                end
                local tilingConfig = TWM.tilingConfigCurrentSpace(windows)
                -- TWM.tilingStrategy[tilingConfig.layout].tile(tilingConfig)
                afterHandelForWindow(tilingConfig)
            end
        end
    end

    spoon.ModalMgr:new("windowM")
    local cmodal = spoon.ModalMgr.modal_list["windowM"]
    cmodal.statusMessage = statusmessage.new("WinMan Mode")
    -- {{{ 右下角状态显示
    cmodal.entered = function()
        cmodal.statusMessage:show()
        cmodal.statusMessage:SMWatcher(cmodal.statusMessage)
    end
    cmodal.exited = function()
        cmodal.statusMessage:hide()
        cmodal.statusMessage:SMWatcher("off")
        hs.alert.closeAll()
    end
    -- 右下角状态显示 }}}

    cmodal:bind("", "escape", "退出 ", function()
        handleWinManMode("exitByManual")
    end)
    cmodal:bind("", "Q", "退出", function()
        handleWinManMode("exitByManual")
    end)
    cmodal:bind("", "tab", "键位提示", function()
        spoon.ModalMgr:toggleCheatsheet()
    end)

    -- {{{ 窗口管理之 原始模式/Tile模式 Start
    hs.fnutils.each(winman_keys, function(item)
        -- 原始模式: 同时只能对一个窗口进行操作, 一个按键只会对应映射一个操作
        if item.tag == "origin" then
            local wfn = item.func
            if wfn == "moveAndResize" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    if item.location == "fullscreen" then
                        spoon.WinMan:moveAndResize(item.location)
                        handleWinManMode("off")
                        return
                    elseif item.location == "maximize" then
                        spoon.WinMan:moveAndResize(item.location)
                        -- handleWinManMode("off")
                        return
                    elseif item.location ~= "shrink" and item.location ~= "expand" then
                        spoon.WinMan:moveAndResize(item.location)
                    else
                        spoon.WinMan:moveAndResize(item.location)
                        spoon.WinMan:moveAndResize(item.location)
                    end
                    handleWinManMode("on")
                end)
            elseif wfn == "stepResize" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    -- spoon.WinMan:stepResize(item.direction)
                    spoon.WinMan:smartStepResize(item.direction)
                    handleWinManMode("on")
                end)
            elseif wfn == "stepMove" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:stepMove(item.direction)
                    handleWinManMode("on")
                end)
            elseif wfn == "wMoveToScreen" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:cMoveToScreen(item.location)
                    handleWinManMode("off")
                end)
            elseif wfn == "moveToSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:moveToSpace(item.direction, item.followWindow)
                    handleWinManMode("off")
                end)
            --[[ elseif wfn == "moveAndFocusToSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:stash()
                    spoon.WinMan:moveToSpace(item.direction)
                    handleWinManMode("on")
                end)
			--]]
            elseif wfn == "killSameAppAllWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    kill_same_application()
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "closeSameAppOtherWindows" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    close_same_application_other_windows()
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "gridWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.GRID)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "flattenWindow" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "rotateLayout" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_application(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL_R)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "flattenWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "gridWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.GRID)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "rotateLayoutWindowsForSpace" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    same_space(AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL_R)
                    -- spoon.ModalMgr:deactivate({"windowM"})
                    handleWinManMode("on")
                end)
            elseif wfn == "undo" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:undo()
                    handleWinManMode("on")
                end)
            elseif wfn == "redo" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:redo()
                    handleWinManMode("on")
                end)
            end
        end

        -- Tile 模式(多 App 窗口同时操作)
        if item.tag == "tile" then
            -- 持久模式下, 改变布局, 不退出窗口管理模式
            if item.layout then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    handleTileWindowLayout(item.layout)
                    handleWinManMode("on")
                end)
            end

            if item.action then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    if item.action == "showLayout" then
                        -- local tilingConfig = TWM.tilingConfigCurrentSpace(true)
                        -- TWM.displayLayout(tilingConfig)
                        TWMObj.displayLayout()
                        -- 重新设定当前 Space 全局布局, 改变布局后立即退出窗口管理模式
                        handleWinManMode("on")
                    elseif item.action == "toogleWindowMouseHover" then
                        TWMObj.toggleFirstMouseHover()
                        handleWinManMode("on")
                    elseif item.action == "switchLayout" then
                        local layoutName = { title = item.tgtLayout }
                        TWMObj.switchLayout(nil, layoutName)
                        if item.tgtLayout == "Floating" then
                            handleWinManMode("exitByFloat")
                        else
                            handleWinManMode("switchAfterExit")
                        end
                    elseif item.action == "focus" or item.action == "swap" then
                        local directionMapVal = { next = 1, prev = -1, first = 0 }
                        handleWindowFocusOrSwap(item.action, directionMapVal[item.direction])
                        handleWinManMode("on")
                    else
                        handleWindowFlexOrResize(item.action, item.sizeVal)
                        handleWinManMode("on")
                    end
                end)
            end
        end
    end)

    -- 定义窗口管理模式快捷键
    local winman_toggle = winman_toggle or { "alt", "R" }
    if string.len(winman_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(winman_toggle[1], winman_toggle[2], "进入窗口管理传统模式", function()
            spoon.ModalMgr:deactivateAll()
            -- 显示状态指示器，方便查看所处模式
            spoon.ModalMgr:activate({ "windowM" }, "#B22222")
        end)
    end
    -- 窗口管理之 传统模式/Tile模式 End }}}
end

-- == 窗口管理之 Grid 轮切模式 == --
if spoon.WinMan then
    local handleMode = function(tag)
        if winman_mode ~= "persistent" or tag == "off" then
            spoon.ModalMgr:deactivate({ "windowRGrid" })
        end
    end

    spoon.ModalMgr:new("windowRGrid")
    local cmodal = spoon.ModalMgr.modal_list["windowRGrid"]
    cmodal.statusMsg = statusmessage.new("WinGridMan Mode")
    cmodal.entered = function()
        cmodal.statusMsg:show()
        cmodal.statusMsg:SMWatcher(cmodal.statusMsg)
    end

    cmodal.exited = function()
        cmodal.statusMsg:hide()
        cmodal.statusMsg:SMWatcher("off")
    end
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
        if not item.mapGridGroup and not item.func then
            return
        end

        if item.tag == "grid" then
            if item.func == "switchToTileMode" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.ModalMgr:deactivateAll()
                    local winman_toggle = winman_toggle or { "alt", "r" }
                    hs.eventtap.keyStroke(winman_toggle[1], winman_toggle[2])
                end)
            elseif item.func == "Redo" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    WTL:redo()
                    handleMode()
                end)
            elseif item.func == "Undo" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    WTL:addToStack("redo", nil) -- Undo 之前将当前窗口的 layout 存入 redoStack
                    WTL:undo()
                    handleMode()
                end)
            elseif item.func == "displayGridUI" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    hs.grid.GRIDWIDTH = reGridWidth
                    hs.grid.GRIDHEIGHT = reGridHeight
                    hs.grid.toggleShow(nil, false)
                    handleMode()
                end)
            elseif item.func == "chooseLayout" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    if window_grid_groups then
                        WGL:chooseLayout(window_group_layouts)
                    else
                        WGL:chooseLayout()
                    end
                    handleMode("off")
                end)
            elseif item.func == "MoveWindowToNextScreen" then
                cmodal:bind(item.prefix, item.key, item.message, function()
                    spoon.WinMan:cMoveToScreen(item.direction)
                    handleMode("off")
                end)
            else
                cmodal:bind(item.prefix, item.key, item.message, function()
                    hs.grid.GRIDWIDTH = GridWidth
                    hs.grid.GRIDHEIGHT = GridHeight
                    WTL:addToStack("undo", nil)
                    rotateWinGrid(item.mapGridGroup)
                    handleMode()
                end)
            end
        end
    end)

    -- 热键触发进入窗口管理Grid模式
    local winGridMan_toggle = winGridMan_toggle or { "alt", "R" }
    if string.len(winGridMan_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(
            winGridMan_toggle[1],
            winGridMan_toggle[2],
            "进入窗口管理 Grid 轮切模式",
            function()
                spoon.ModalMgr:deactivateAll()
                -- 显示状态指示器，方便查看所处模式
                spoon.ModalMgr:activate({ "windowRGrid" }, "#C88888")
            end
        )
    end
end

spoon.ModalMgr.supervisor:enter()

--! App 窗口开启全局任意方式切换后自动调整布局, 有一定程度性能会下降!
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
--[[ TilingWindowManager 独立配置如下
local Shyper = { "Ctrl", "Option", "Cmd" }
hs.loadSpoon("TilingWindowManager")
    :setLogLevel("debug")
    :bindHotkeys({
        tile =           {Shyper, "t"},
        incMainRatio =   {Shyper, "p"},
        decMainRatio =   {Shyper, "o"},
        incMainWindows = {Shyper, "i"},
        decMainWindows = {Shyper, "u"},
        focusPrev =      {Shyper, "k"},
        focusNext =      {Shyper, "j"},
        swapNext =       {Shyper, "l"},
        swapPrev =       {Shyper, "h"},
        toggleFirst =    {Shyper, "return"},
        tall =           {Shyper, ","},
        talltwo =        {Shyper, "m"},
        fullscreen =     {Shyper, "."},
        wide =           {Shyper, ";"},
        display =        {Shyper, "d"},
    })
    :start({
        menubar = true,
        dynamic = false,
        layouts = {
            spoon.TilingWindowManager.layouts.fullscreen,
            spoon.TilingWindowManager.layouts.tall,
            spoon.TilingWindowManager.layouts.talltwo,
            spoon.TilingWindowManager.layouts.wide,
            spoon.TilingWindowManager.layouts.floating,
        },
        displayLayout = true,
        floatApps = {
            "com.apple.Finder",
        }
    })

hs.hotkey.bind(Shyper, 'y', 'stop' , function ()
    hs.loadSpoon("TilingWindowManager"):toggleTWM({
        menubar = true,
        dynamic = false,
        layouts = {
            floating = "Floating",
            fullscreen = "Fullscreen",
            tall = "Tall",
            wide = "Wide",
            talltwo = "Tall Two Pane"
        },
        displayLayout = true,
        floatApps = {
            "com.apple.Finder",
        }
    })
end)
--]]

--[[
cmodal:bind('', 'A', '向左移动', function() spoon.WinMan:stepMove("left") end, nil, function() spoon.WinMan:stepMove("left") end)
cmodal:bind('', 'D', '向右移动', function() spoon.WinMan:stepMove("right") end, nil, function() spoon.WinMan:stepMove("right") end)
cmodal:bind('', 'W', '向上移动', function() spoon.WinMan:stepMove("up") end, nil, function() spoon.WinMan:stepMove("up") end)
cmodal:bind('', 'S', '向下移动', function() spoon.WinMan:stepMove("down") end, nil, function() spoon.WinMan:stepMove("down") end)

cmodal:bind('', 'H', '左半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfleft") end)
cmodal:bind('', 'L', '右半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfright") end)
cmodal:bind('', 'K', '上半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfup") end)
cmodal:bind('', 'J', '下半屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("halfdown") end)

cmodal:bind('', 'Y', '屏幕左上角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerNW") end)
cmodal:bind('', 'O', '屏幕右上角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerNE") end)
cmodal:bind('', 'U', '屏幕左下角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerSW") end)
cmodal:bind('', 'I', '屏幕右下角', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("cornerSE") end)

cmodal:bind('', 'F', '全屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("fullscreen") end)
cmodal:bind('', 'C', '居中', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("center") end)
cmodal:bind('', 'G', '左三分之二屏居中分屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("centermost") end)
cmodal:bind('', 'Z', '展示显示', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("show") end)
cmodal:bind('', 'V', '编辑显示', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("shows") end)

cmodal:bind('', 'X', '二分之一居中分屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("center-2") end)

cmodal:bind('', '=', '窗口放大', function() spoon.WinMan:moveAndResize("expand") end, nil,
function() Spoon.WinMan:spoon.WinMan:moveAndResize("expand") end)
cmodal:bind('', '-', '窗口缩小', function() spoon.WinMan:moveAndResize("shrink") end, nil,
function() spoon.WinMan:moveAndResize("shrink") end)

cmodal:bind('ctrl', 'H', '向左收缩窗口', function() spoon.WinMan:stepResize("left") end, nil, function() spoon.WinMan:stepResize("left") end)
cmodal:bind('ctrl', 'L', '向右扩展窗口', function() spoon.WinMan:stepResize("right") end, nil, function() spoon.WinMan:stepResize("right") end)
cmodal:bind('ctrl', 'K', '向上收缩窗口', function() spoon.WinMan:stepResize("up") end, nil, function() spoon.WinMan:stepResize("up") end)
cmodal:bind('ctrl', 'J', '向下扩镇窗口', function() spoon.WinMan:stepResize("down") end, nil, function() spoon.WinMan:stepResize("down") end)

cmodal:bind('', 'left', '窗口移至左边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("left") end)
cmodal:bind('', 'right', '窗口移至右边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("right") end)
cmodal:bind('', 'up', '窗口移至上边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("up") end)
cmodal:bind('', 'down', '窗口移动下边屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("down") end)
cmodal:bind('', 'space', '窗口移至下一个屏幕', function() spoon.WinMan:stash() spoon.WinMan:moveToScreen("next") end)
cmodal:bind('', 'B', '撤销最后一个窗口操作', function() spoon.WinMan:undo() end)
cmodal:bind('', 'R', '重做最后一个窗口操作', function() spoon.WinMan:redo() end)

cmodal:bind('', '[', '左三分之二屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("mostleft") end)
cmodal:bind('', ']', '右三分之二屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("mostright") end)
cmodal:bind('', ',', '左三分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("lesshalfleft") end)
cmodal:bind('', '.', '中分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("onethird") end)
cmodal:bind('', '/', '右三分之一屏', function() spoon.WinMan:stash() spoon.WinMan:moveAndResize("lesshalfright") end)

cmodal:bind('', 't', '将光标移至所在窗口中心位置', function() spoon.WinMan:centerCursor() end)
--]]
