-- 窗口快捷调整大小和布局

hs.loadSpoon("ModalMgr")
hs.loadSpoon("WinMan")
require("modules.shortcut")
require("modules.window")
-- require 'modules.remapkey'

-- 窗口自动布局方式枚举
local AUTO_LAYOUT_TYPE = {
    -- 网格式布局
    GRID = "GRID",
    -- 水平或垂直评分
    HORIZONTAL_OR_VERTICAL = "HORIZONTAL_OR_VERTICAL",
    HORIZONTAL_OR_VERTICAL_R = "ROTATE",
}

-- 定义窗口管理模式快捷键
if spoon.WinMan then
    local handleMode = function()
        if winman_mode ~= "persistent" then
            spoon.ModalMgr:deactivate({ "windowM" })
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

    hs.fnutils.each(winman_keys, function(item)
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
    end)

    -- 定义窗口管理模式快捷键
    local winman_toggle = winman_toggle or { "alt", "R" }
    if string.len(winman_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(winman_toggle[1], winman_toggle[2], "进入窗口管理模式", function()
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
end

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
    cmodal:bind("", "H", "LeftGrid", function()
        rotateWinGrid({
            grid.leftHalf,
            grid.leftThird,
            grid.leftTwoThirds,
        })
        handleMode()
    end)
    cmodal:bind("", "L", "RightGrid", function()
        rotateWinGrid({
            grid.rightHalf,
            grid.rightThird,
            grid.rightTwoThirds,
        })
        handleMode()
    end)
    cmodal:bind("", "K", "TopGrid", function()
        rotateWinGrid({
            grid.topHalf,
            grid.topThird,
            grid.topTwoThirds,
        })
        handleMode()
    end)
    cmodal:bind("", "J", "BottomGrid", function()
        rotateWinGrid({
            grid.bottomHalf,
            grid.bottomThird,
            grid.bottomTwoThirds,
        })
        handleMode()
    end)
    cmodal:bind("", "C", "CenterGrid", function()
        rotateWinGrid({
            grid.fullScreen,
            grid.centeredBig,
            grid.centeredMedium,
            grid.centerHorizontal,
            grid.centerVertical,
        })
        handleMode()
    end)
    cmodal:bind("", "S", "cornerGrid", function()
        rotateWinGrid({
            grid.topLeft,
            grid.topRight,
            grid.bottomRight,
            grid.bottomLeft,
        })
        handleMode()
    end)

    -- 定义窗口管理模式快捷键
    local winGridMan_toggle = winGridMan_toggle or { "alt", "R" }
    if string.len(winGridMan_toggle[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(
            winGridMan_toggle[1],
            winGridMan_toggle[2],
            "进入窗口管理模式",
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
