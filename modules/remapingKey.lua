-- 按键重映射

hs.loadSpoon("WinMan")
hs.loadSpoon("MenuChooserMod")
local MC = spoon.MenuChooserMod

require("configs.remapingShortcuts")

local function pressTargetKey(tgtkey)
    hs.eventtap.keyStroke(tgtkey[1], tgtkey[2])
end

local function getTargetSpaceID(direction)
    local curSpaceID = hs.spaces.focusedSpace()
    local curScreenAllSpaceIDs = hs.spaces.spacesForScreen()
    table.sort(curScreenAllSpaceIDs)
    local nextSpaceIndex = hs.fnutils.indexOf(curScreenAllSpaceIDs, curSpaceID)
    if nextSpaceIndex == #curScreenAllSpaceIDs then
        if direction == "next" then
            nextSpaceIndex = 1
        else
            nextSpaceIndex = nextSpaceIndex - 1
        end
    else
        if direction == "next" then
            nextSpaceIndex = nextSpaceIndex + 1
        else
            nextSpaceIndex = nextSpaceIndex - 1
            -- if nextSpaceIndex == 0 then
            --     nextSpaceIndex = #curScreenAllSpaceIDs
            -- end
        end
    end
    return curScreenAllSpaceIDs[nextSpaceIndex], nextSpaceIndex
end

local function execTargetFunc(tgtfn)
    if tgtfn == "menuchooser" then
        MC.chooseMenuItem()
    elseif tgtfn == "goToNextSpace" then
        local nextSpaceID, nextSpaceIndex = getTargetSpaceID("next")
        if nextSpaceIndex == 1 then
            -- 仅能通过调用快捷键来切换到第一个桌面空间
            if remapingKeys.switchToFirstSpaceHotKey then
                pressTargetKey(remapingKeys.switchToFirstSpaceHotKey)
            end
        else
            hs.spaces.gotoSpace(nextSpaceID)
        end
    elseif tgtfn == "goToPreSpace" then
        local prevSpaceID, prevSpaceIndex = getTargetSpaceID("prev")
        -- 无法在桌面空间(Space)个数不确定情况下, 从第一个 Space 跳到最后一个
        if prevSpaceID or prevSpaceIndex then
            hs.spaces.gotoSpace(prevSpaceID)
        end
    elseif tgtfn == "windowMaximze" then
        local cwin = hs.window.focusedWindow()
        cwin:maximize()
    elseif tgtfn == "windowMinimize" then
        local cwin = hs.window.focusedWindow()
        cwin:minimize()
        hs.eventtap.keyStroke({ "cmd" }, "H")
    else
        spoon.WinMan:jumpToWindowAndFocus()
    end
end

hs.fnutils.each(remapingKeys, function(item)
    if item.key then
        hs.hotkey.bind(item.prefix, item.key, item.message, function()
            if item.targetKey then
                pressTargetKey(item.targetKey)
            else
                execTargetFunc(item.targetFunc)
            end
        end)
    end
end)
