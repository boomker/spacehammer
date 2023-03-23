---@diagnostic disable: lowercase-global
hs.loadSpoon("FocusHighlight")
require("modules.caffeine")
require("configs.shortcuts")

local fhl = spoon.FocusHighlight

function screenCenter()
    local cwin = hs.window.focusedWindow()
    -- local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:fullFrame()
    -- if cwin then
    -- Center the cursor one the focused window
    -- hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
    -- else
    -- Center the cursor on the screen
    hs.mouse.absolutePosition({ x = cres.x + cres.w / 2, y = cres.y + cres.h / 2 })
    -- end
end

function screenTopLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h / 4)
    hs.mouse.absolutePosition(newPoint)
end

function screenTopRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h / 4)
    hs.mouse.absolutePosition(newPoint)
end

function screenBottomLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h * 3 / 4)
    hs.mouse.absolutePosition(newPoint)
end

function screenBottomRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h * 3 / 4)
    hs.mouse.absolutePosition(newPoint)
end

function removeDeskTopSpace()
    local osascript = [[
        my closeSpace()

        on closeSpace()
            tell application "Mission Control" to launch
            delay 0.5
            tell application "System Events"
                tell list 1 of group 2 of group 1 of group 1 of process "Dock"
                    set countSpaces to count of buttons
                    if countSpaces is greater than 1 then
                        perform action "AXRemoveDesktop" of button countSpaces
                    end if
                end tell
                delay 0.3
                key code 53 --  # Esc key on US English Keyboard
            end tell
        end closeSpace
    ]]
    local ok, _, _ = hs.osascript.applescript(osascript)
    if ok then
        hs.alert.show("桌面空间已移除", 0.5)
    end
end

function addDeskTopSpace()
    local osascript = [[
        do shell script "open -b 'com.apple.exposelauncher'"
        delay 0.5
        tell application id "com.apple.systemevents"
            tell (every application process whose bundle identifier = "com.apple.dock") to click (button 1 of group 2 of group 1 of group 1)
            delay 0.3
            key code 53 -- esc key
        end tell
    ]]
    local ok, _, _ = hs.osascript.applescript(osascript)
    if ok then
        hs.alert.show("桌面空间已添加", 0.5)
    end
end

function getBluetoothState()
    local btState = string.format("/usr/local/bin/blueutil -p")
    local retVal, status, _, exitCode = hs.execute(btState)
    if retVal == "1" and exitCode == "0" then
        return true
    else
        return false
    end
end

function toggleBluetooth(actState)
    if getBluetoothState() and actState == "off" then
        local btOff = string.format("/usr/local/bin/blueutil -p 0")
        local retVal, status, _, exitCode = hs.execute(btOff)
        if exitCode == "0" then
            hs.alert.show("蓝牙设备已关闭", 0.5)
        end
    elseif not getBluetoothState() and actState == "on" then
        local btOn = string.format("/usr/local/bin/blueutil -p 1")
        local retVal, status, _, exitCode = hs.execute(btOn)
        if exitCode == "0" then
            hs.alert.show("蓝牙设备已打开", 0.5)
        end
    end
end

function connetBluetoothDevice()
    toggleBluetooth("on")
    local favoriteBluetoothName = superKey_items.favoriteBluetoothName or "小爱音箱-4099"
    local btdUIDFindCMDStr =
        string.format("/usr/local/bin/blueutil --paired |awk -F'[: ,]+' '/%s/{print $2}'", favoriteBluetoothName)
    local ok1, btUID, _ = hs.osascript.applescript(string.format('do shell script "%s"', btdUIDFindCMDStr))
    if not ok1 then
        hs.alert.show("未找到目标蓝牙设备", 0.5)
    else
        local isConnectedCMDStr = string.format("/usr/local/bin/blueutil --is-connecte %s", btUID)
        local ok2, isConnected, _ = hs.osascript.applescript(string.format('do shell script "%s"', isConnectedCMDStr))
        if ok2 and isConnected == "0" then
            local connetBTDCMDStr = string.format("/usr/local/bin/blueutil --connect %s", btUID)
            local ok3, _, _ = hs.osascript.applescript(string.format('do shell script "%s"', connetBTDCMDStr))
            if ok3 then
                hs.alert.show("蓝牙连接成功", 0.5)
            else
                hs.alert.show("蓝牙连接失败", 0.5)
            end
        else
            local disConnetBTDCMDStr = string.format("/usr/local/bin/blueutil --disconnect %s", btUID)
            local ok4, _, _ = hs.osascript.applescript(string.format('do shell script "%s"', disConnetBTDCMDStr))
            if ok4 then
                hs.alert.show("蓝牙已断开连接", 0.5)
            else
                hs.alert.show("蓝牙未断开连接", 0.5)
            end
        end
    end
end

function toggleDarkMode()
    local darkModeOSAScriptStr = [[
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
    ]]

    local ok, _, _ = hs.osascript.applescript(darkModeOSAScriptStr)
    if ok then
        hs.alert.show("暗夜模式切换成功", 0.5)
    end
end

function enableFocuseMode()
    if hs.settings.get("enableFocuseMode") then
        -- hs.window.highlight.stop()
        fhl:stop()
        hs.settings.set("enableFocuseMode", false)
    else
        -- hs.window.highlight.ui.overlay = true
        -- hs.window.highlight.ui.flashDuration = 0.1
        -- hs.window.highlight.start()
        fhl.color = "#f9bc34"
        fhl.windowFilter = hs.window.filter.default
        fhl.arrowSize = 128
        fhl.arrowFadeOutDuration = 1
        fhl.highlightFadeOutDuration = 2
        fhl.highlightFillAlpha = 0.3
        fhl:start()
        hs.settings.set("enableFocuseMode", true)
    end
end

function togglecaffeineMode()
    -- if caffConfig and caffConfig.caffeine == 'on' then
    toggleCaffeine()
    -- caffConfig.caffeine = 'off'
    -- else
    --     unsetCaffeine()
    -- end
end

function ejectAllDMG()
    local cmdStr =
        "diskutil list |/usr/bin/grep 'disk image' |/usr/bin/cut -f1 -d' ' |/usr/bin/xargs -I d diskutil eject d"
    local retVal, _, retCode = os.execute(cmdStr)
    if retVal and retCode == 0 then
        hs.alert.show("成功推出所有DMG", 0.5)
    end
end

function forceKillCurApp()
    local cwin = hs.window.focusedWindow()
    local capp = cwin:application()
    capp:kill9()
    hs.alert.show("当前应用强制退出中...", 0.5)
end

function restartMac()
    local rebootScrStr = 'tell application "Finder" to restart'
    local ok, _, _ = hs.osascript.applescript(rebootScrStr)
    if ok then
        hs.alert.show("重启")
    end
end

function toggleMute()
    local curAudio = hs.audiodevice.defaultEffectDevice()
    local isMuted = curAudio:muted()
    if isMuted then
        curAudio:setMuted(false)
        hs.alert.show("取消静音", 0.5)
    else
        curAudio:setMuted(true)
        hs.alert.show("系统已静音", 0.5)
    end
end

function toggleMicrophoneMute()
    local curInputAudio = hs.audiodevice.defaultInputDevice()
    local isMuted = curInputAudio:muted()
    if isMuted then
        curInputAudio:setMuted(false)
        hs.alert.show("麦克风已开启", 0.5)
    else
        curInputAudio:setMuted(true)
        hs.alert.show("麦克风已静音", 0.5)
    end
end

function openSecAndPrivacy()
    hs.alert.show("安全与隐私正在打开...")
    local openSecPrivSetting = [[
			tell application "System Preferences"
				reveal anchor "Privacy_Accessibility" of pane "com.apple.preference.security"
				activate
			end tell
		]]
    local ok, _, _ = hs.osascript.applescript(openSecPrivSetting)
    if not ok then
        hs.alert.show("安全与隐私打开失败", 0.5)
    end
end

function oneKeyUpgradeBrews()
    local proxyCMD = nil
    if superKey_items.httpProxy then
        proxyCMD = string.format("export http_proxy=%s ;", superKey_items.httpProxy)
    else
        proxyCMD = ""
    end
    local brewUpgradeCMD = "brew outdated |awk '$0 !~ /pin/{print $1}' |xargs -P 0 brew upgrade > /dev/null 2>&1 &"
    local cmd = string.format("%s %s", proxyCMD, brewUpgradeCMD)
    local _, status, _, exitCode = hs.execute(cmd, true)

    if status and exitCode == 0 then
        hs.alert.show("Brew正在更新...")
    end
end
