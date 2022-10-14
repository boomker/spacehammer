---@diagnostic disable: lowercase-global
hs.loadSpoon("ModalMgr")
hs.loadSpoon("KSheet")
-- require 'configs.shortcuts'

-- if spoon.KSheet then

    -- 定义快捷键
    -- local hscheats_keys = hscheats_keys or {HyperKey, "S"}
    -- if string.len(hscheats_keys[2]) > 0 then
    --     spoon.ModalMgr.supervisor:bind(hscheats_keys[1], hscheats_keys[2], "显示当前应用快捷键", function()
    --         spoon.KSheet:show()
    --         spoon.ModalMgr:deactivateAll()
    --         spoon.ModalMgr:activate({"cheatsheetM"})
    --     end)
    -- end
-- end


function showAppShortCutsPane()
    spoon.KSheet:show()
    spoon.ModalMgr:deactivateAll()
    spoon.ModalMgr:new("cheatsheetM")
    local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cmodal:bind('', 'escape', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    spoon.ModalMgr:activate({"cheatsheetM"})
end

spoon.ModalMgr.supervisor:enter()