hs.loadSpoon("ModalMgr")
require 'modules.shortcut'
require 'modules.ksheet'
require 'modules.hotkeyHelper'
require 'modules.caffeine'

local skmodal = nil
if spoon.ModalMgr then
	spoon.ModalMgr:new("SuperKey")
	skmodal = spoon.ModalMgr.modal_list["SuperKey"]

	-- skmodal = hs.hotkey.modal.new(superKey_toggle[1], superKey_toggle[2], "进入SuperKey模式")
	skmodal:bind('', 'escape', 'exit SuperKey模式', function() spoon.ModalMgr:deactivate({"SuperKey"}) end)
	skmodal:bind('', 'Q', 'exit SuperKey模式', function() spoon.ModalMgr:deactivate({"SuperKey"}) end)
    skmodal:bind('', 'tab', '键位提示', function() spoon.ModalMgr:toggleCheatsheet() end)
	skmodal:bind('', 'Z', '显示桌面', function() hs.spaces.toggleShowDesktop() spoon.ModalMgr:deactivate({"SuperKey"}) end)
	skmodal:bind('', 'S', 'KSheet看应用热键', function() enterCheatsheetM() spoon.ModalMgr:deactivate({"SuperKey"}) end)
	skmodal:bind('', 'H', '打开快捷键显示面板', function() enterShowHSHotKeyPane() spoon.ModalMgr:deactivate({"SuperKey"}) end)
	skmodal:bind('', 'G', '光标移动到屏幕中心', function()
        local windowCenter = hs.window.frontmostWindow():frame().center
        hs.mouse.absolutePosition(windowCenter)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'Y', '光标移动到屏幕左上角', function()
        local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
        local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h / 4)
        hs.mouse.absolutePosition(newPoint)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'U', '光标移动到屏幕右上角', function()
        local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
        local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h / 4)
        hs.mouse.absolutePosition(newPoint)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'I', '光标移动到屏幕左下角', function()
        local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
        local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h * 3 / 4)
        hs.mouse.absolutePosition(newPoint)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'O', '光标移动到屏幕右下角', function()
        local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
        local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h * 3 / 4)
        hs.mouse.absolutePosition(newPoint)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'X', '移除桌面空间', function()
        local osascript = [[
            my closeSpace()

            on closeSpace()
                tell application "Mission Control" to launch
                delay 1
                tell application "System Events"
                    tell list 1 of group 2 of group 1 of group 1 of process "Dock"
                        set countSpaces to count of buttons
                        if countSpaces is greater than 1 then
                            perform action "AXRemoveDesktop" of button countSpaces
                        end if
                    end tell
                    delay 0.5
                    key code 53 --  # Esc key on US English Keyboard
                end tell
            end closeSpace
        ]]
        local ok, _, _ = hs.osascript.applescript(osascript)
        if ok then hs.alert.show("桌面空间已移除", 0.5) end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind('', 'A', '新增桌面空间', function()
        local osascript = [[
            do shell script "open -b 'com.apple.exposelauncher'"
            delay 0.5
            tell application id "com.apple.systemevents"
                tell (every application process whose bundle identifier = "com.apple.dock") to click (button 1 of group 2 of group 1 of group 1)
                delay 0.5
                key code 53 -- esc key
            end tell
        ]]
        local ok, _, _ = hs.osascript.applescript(osascript)
        if ok then hs.alert.show("桌面空间已添加", 0.5) end
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
	skmodal:bind('', 'B', '蓝牙开关连接', function()
		local favoriteBluetoothName = superKey_items.favoriteBluetoothName or '小爱音箱-4099'
		local btdUIDFindCMDStr = string.format("/usr/local/bin/blueutil --paired |/usr/bin/grep %s |/usr/bin/cut -f1 -d',' |cut -c 10-", favoriteBluetoothName)
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
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'N', '开关勿扰模式', function()
		hs.eventtap.keyStroke(superKey_items.toggleDND[1], superKey_items.toggleDND[2])
		hs.alert.show("勿扰模式切换成功",0.5)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'D', '暗夜模式切换', function()
		local darkModeOSAScriptStr = [[
			tell application "System Events"
				tell appearance preferences
					set dark mode to not dark mode
				end tell
			end tell
		]]

		local ok, _, _ = hs.osascript.applescript(darkModeOSAScriptStr)
		if ok then hs.alert.show("暗夜模式切换成功", 0.5) end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind('', 'F', '开启专注模式', function()
        if hs.settings.get('enableFocuseMode') then
            hs.window.highlight.stop()
        else
            hs.window.highlight.ui.overlay=true
            hs.window.highlight.ui.flashDuration=0.1
            hs.window.highlight.start()
            hs.settings.set('enableFocuseMode', true)
        end
        -- hs.window.highlight.toggleIsolate(true)
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
    skmodal:bind('', 'C', 'caffeineMode', function()
        if caffConfig ~= nil and caffConfig.caffeine == 'on' then
            setCaffeine()
            --监听咖啡因的状态,判断是否要重置
            -- hs.timer.doEvery(1, resetCaffeineMeun)
            caffConfig.caffeine = 'off'
        else
            unsetCaffeine()
        end
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
	skmodal:bind('', 'E', 'eject所有DMG磁盘', function()
		local cmdStr = "diskutil list |/usr/bin/grep 'disk image' |/usr/bin/cut -f1 -d' ' |/usr/bin/xargs -I d diskutil eject d"
		local retVal, _, retCode = os.execute(cmdStr)
		if retVal and retCode == 0 then
			hs.alert.show("成功推出所有DMG", 0.5)
		end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'K', '强杀应用', function()
		local cwin = hs.window.focusedWindow()
		local capp = cwin:application()
		capp:kill9()
        hs.alert.show("当前应用强制退出中...", 0.5)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'L', '锁屏', function()
		hs.eventtap.keyStroke({'Cmd', 'Ctrl'}, 'Q')
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'R', '重启', function()
		local rebootScrStr = 'tell application "Finder" to restart'
		local ok, _, _ = hs.osascript.applescript(rebootScrStr)
		if ok then hs.alert.show("重启") end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'J', '静音', function()
		local curAudio = hs.audiodevice.defaultEffectDevice()
		local isMuted = curAudio:muted()
		if isMuted then
			curAudio:setMuted(false)
			hs.alert.show("取消静音", 0.5)
		else
			curAudio:setMuted(true)
			hs.alert.show("系统已静音", 0.5)
		end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'M', '麦克风开关静音', function()
		local curInputAudio = hs.audiodevice.defaultInputDevice()
		local isMuted = curInputAudio:muted()
		if isMuted then
			curInputAudio:setMuted(false)
			hs.alert.show("麦克风已开启", 0.5)
		else
			curInputAudio:setMuted(true)
			hs.alert.show("麦克风已静音", 0.5)
		end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'P', '打开安全与隐私', function()
		hs.alert.show("安全与隐私正在打开...")
		local openSecPrivSetting = [[
			tell application "System Preferences"
				reveal anchor "Privacy_Accessibility" of pane "com.apple.preference.security"
				activate
			end tell
		]]
		local ok, _, _ = hs.osascript.applescript(openSecPrivSetting)
		if not ok then hs.alert.show("安全与隐私打开失败", 0.5) end
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'T', '打开活动监视器', function()
        hs.application.launchOrFocusByBundleID("com.apple.ActivityMonitor")
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'V', 'pastePasswords', function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind({"Shift"}, 'U', '一键升级brew', function()
        local proxyCMD = nil
        if superKey_items.httpProxy then
            proxyCMD = string.format('export http_proxy=%s ;', superKey_items.httpProxy)
        else
            proxyCMD = ''
        end
        local brewUpgradeCMD = "brew outdated |awk '$0 !~ /pin/{print $1}' |xargs -P 0 brew upgrade > /dev/null 2>&1 &"
        local cmd = string.format("%s %s", proxyCMD, brewUpgradeCMD)
        local _, status, _, exitCode = hs.execute(cmd, true)
        if status and exitCode == 0 then
            hs.alert.show("Brew正在更新...")
        end

		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
	skmodal:bind({"Shift"}, 'I', '打开Bartender搜索面板', function()
		hs.eventtap.keyStroke(superKey_items.bartenderMenuSearch[1], superKey_items.bartenderMenuSearch[2])
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind({"Shift"}, 'O', '打开BobOCR', function()
		hs.eventtap.keyStroke(superKey_items.bobOCR[1], superKey_items.bobOCR[2])
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)

    spoon.ModalMgr.supervisor:bind(superKey_toggle[1], superKey_toggle[2], "进入SuperKey模式", function()
        spoon.ModalMgr:deactivateAll()
        -- 显示状态指示器，方便查看所处模式
        spoon.ModalMgr:activate({"SuperKey"}, "#C99999")
    end)
end


local message = require('modules.status-message')
skmodal.statusMessage = message.new('SuperKey Mode')
skmodal.entered = function()
    skmodal.statusMessage:show()
end

skmodal.exited = function()
    skmodal.statusMessage:hide()
end

spoon.ModalMgr.supervisor:enter()