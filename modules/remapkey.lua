-- 按键重映射

-- require 'modules.base'
hs.loadSpoon("WinMan")
require 'modules.shortcut'

hs.fnutils.each(remapkeys, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        if item.targetKey then
            pressTargetKey(item.targetKey)
        else
            execTargetFunc(item.targetFunc)
        end
    end)
end)


function pressTargetKey(tgtkey)
    hs.eventtap.keyStroke(tgtkey[1], tgtkey[2])
end

local function getTargetSpaceID(direction)
    local curSpaceID = hs.spaces.focusedSpace()
    local curScreenAllSpaceIDs = hs.spaces.spacesForScreen()
    local nextSpaceID = 0
    local nsi = 0
    if direction == 'next' then
        for i, v in ipairs(curScreenAllSpaceIDs) do
            if curSpaceID < v then
                nextSpaceID = v
                nsi = i
                break
            end
        end
    else
        for i, v in ipairs(curScreenAllSpaceIDs) do
            if curSpaceID > v then
                nextSpaceID = v
                nsi = i
                break
            end
        end
    end
    return nextSpaceID, nsi
end


function execTargetFunc(tgtfn)
    if tgtfn == "toggleShowDesktop" then
        hs.spaces.toggleShowDesktop()
    elseif tgtfn == "goToNextSpace" then
        local nextSpaceID, nsi  = getTargetSpaceID('next')
        if nextSpaceID == 0 and nsi == 0 then
            nextSpaceID = 1
            nsi = 1
            -- 仅能通过调用快捷键来切换到第一个桌面空间
            -- pressTargetKey({ { "cmd", "alt", "ctrl" }, "," })
            pressTargetKey(firstDesktopSpaceHotKey)
        else
            hs.spaces.gotoSpace(nextSpaceID)
        end
    elseif tgtfn == "goToPreSpace" then
        local nextSpaceID, nsi  = getTargetSpaceID('prev')
        -- print(nsi, nextSpaceID)
        -- 无法在桌面空间个数不确定情况下, 从第一个 Space 跳到最后一个
        if not nextSpaceID == 0 and not nsi == 0 then
            hs.spaces.gotoSpace(nextSpaceID)
        end
    else
        spoon.WinMan:jumpToWindowAndFocus()
    end
end
