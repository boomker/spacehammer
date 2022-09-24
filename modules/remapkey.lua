-- 按键重映射

require 'modules.base'
require 'modules.shortcut'

hs.fnutils.each(remapkeys, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        if item.targetKey then
            pressTargetKey(item.targetKey)
        else
            execTarggetFunc(item.targetFunc)
        end
    end)
end)


function pressTargetKey(tgtkey)
    hs.eventtap.keyStroke(tgtkey[1], tgtkey[2])
end

function execTarggetFunc(tgtfn)
    if tgtfn == "toggleShowDesktop" then
        hs.spaces.toggleShowDesktop()
    -- elseif tgtfn == "goToSpace" then
    --     local sInfo = hs.spaces.data_managedDisplaySpaces()
    --     print(serialize(sInfo))
    end
end
