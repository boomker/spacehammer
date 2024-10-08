hs.loadSpoon("ModalMgr")
require("modules.base")
require("modules.ksheet")
require("configs.shortcuts")
require("modules.superSCore")
require("modules.hotkeyHelper")

-- local skmodal = {}
if spoon.ModalMgr then
    spoon.ModalMgr:new("SuperSKey")
    ------------------------------------------------------------
    local skmodal = spoon.ModalMgr.modal_list["SuperSKey"]
    local message = require("modules.status-message")
    skmodal.statusMessage = message.new("SuperSKey Mode")
    skmodal.entered = function()
        skmodal.statusMessage:show()
        skmodal.statusMessage:SMWatcher(skmodal.statusMessage)
    end

    skmodal.exited = function()
        skmodal.statusMessage:hide()
        skmodal.statusMessage:SMWatcher("off")
    end

    skmodal:bind("", "escape", "exit SuperSKey模式", function()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "Q", "exit SuperSKey模式", function()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "tab", "键位提示", function()
        spoon.ModalMgr:toggleCheatsheet()
    end)
    skmodal:bind("", "Z", "显示桌面", function()
        hs.spaces.toggleShowDesktop()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "S", "KSheet看应用热键", function()
        showAppShortCutsPane()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "W", "显示窗口管理所有热键", function()
        showHSHotKeysPane("WindowMOnly")
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "H", "打开快捷键显示面板", function()
        showHSHotKeysPane("all")
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "G", "光标移动到屏幕中心", function()
        screenCenter()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "Y", "光标移动到屏幕左上角", function()
        screenTopLeft()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "U", "光标移动到屏幕右上角", function()
        screenTopRight()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "I", "光标移动到屏幕左下角", function()
        screenBottomLeft()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "O", "光标移动到屏幕右下角", function()
        screenBottomRight()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "X", "移除桌面空间", function()
        removeDeskTopSpace()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "A", "新增桌面空间", function()
        addDeskTopSpace()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "B", "蓝牙开关连接", function()
        connetBluetoothDevice()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "N", "开关勿扰模式", function()
        hs.eventtap.keyStroke(superKey_items.toggleDND[1], superKey_items.toggleDND[2])
        hs.alert.show("勿扰模式切换成功", 0.5)
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "D", "暗夜模式切换", function()
        toggleDarkMode()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "F", "开启专注模式", function()
        enableFocuseMode()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "C", "caffeineMode", function()
        togglecaffeineMode()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "E", "eject所有DMG磁盘", function()
        ejectAllDMG()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "K", "强杀应用", function()
        forceKillCurApp()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "L", "锁屏", function()
        hs.eventtap.keyStroke({ "Cmd", "Ctrl" }, "Q")
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "R", "重启", function()
        restartMac()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "J", "🔈扬声器静音", function()
        toggleMute()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "M", "🎤麦克风开关静音", function()
        toggleMicrophoneMute()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "P", "Play/Pause", function()
        require("hs.eventtap").event.newSystemKeyEvent("PLAY", true):post()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind({ "Shift" }, "P", "打开安全与隐私", function()
        openSecAndPrivacy()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "T", "打开活动监视器", function()
        hs.application.launchOrFocusByBundleID("com.apple.ActivityMonitor")
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind("", "V", "粘贴密码", function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind({ "Shift" }, "U", "一键升级brew", function()
        oneKeyUpgradeBrews()
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind({ "Shift" }, "I", "打开Bartender搜索面板", function()
        hs.eventtap.keyStroke(superKey_items.bartenderMenuSearch[1], superKey_items.bartenderMenuSearch[2])
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)
    skmodal:bind({ "Shift" }, "O", "打开EasydictOCR", function()
        hs.eventtap.keyStroke(superKey_items.EasydictOCR[1], superKey_items.EasydictOCR[2])
        spoon.ModalMgr:deactivate({ "SuperSKey" })
    end)

    spoon.ModalMgr.supervisor:bind(superKey_toggle[1], superKey_toggle[2], "进入SuperSKey模式", function()
        spoon.ModalMgr:deactivateAll()
        -- 显示状态指示器，方便查看所处模式
        spoon.ModalMgr:activate({ "SuperSKey" }, "#C99999")
    end)
end

--------------- 开机登陆后自动化任务 -----------------------
local function judge_boot()
    local uptime_cmd = [[uptime |cut -d',' -f1 |awk '{gsub(/:/, "");print $(NF-1), $NF}']]
    local uptime_res, _, _, _ = hs.execute(uptime_cmd)
    local retVals = split(trim(uptime_res), " ")
    if not retVals then return false end
    if string.match(retVals[2], "secs") then
        return true
    elseif string.match(retVals[2], "day") then
        return false
    elseif string.match(retVals[2], "mins") and tonumber(retVals[1]) <= 2 then
        return true
    end
    return false
end

local function connect_bluetooth()
    if judge_boot() then
        connetBluetoothDevice()
    end
end

connect_bluetooth()

spoon.ModalMgr.supervisor:enter()
