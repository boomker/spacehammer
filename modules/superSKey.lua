hs.loadSpoon("ModalMgr")
require 'modules.shortcut'
require 'modules.superSCore'
require 'modules.ksheet'
require 'modules.hotkeyHelper'

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
        screenCenter()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'Y', '光标移动到屏幕左上角', function()
        screenTopLeft()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'U', '光标移动到屏幕右上角', function()
        screenTopRight()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'I', '光标移动到屏幕左下角', function()
        screenBottomLeft()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'O', '光标移动到屏幕右下角', function()
        screenBottomRight()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'X', '移除桌面空间', function()
        removeDeskTopSpace()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind('', 'A', '新增桌面空间', function()
        addDeskTopSpace()
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
	skmodal:bind('', 'B', '蓝牙开关连接', function()
        toggleBluetooth()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'N', '开关勿扰模式', function()
		hs.eventtap.keyStroke(superKey_items.toggleDND[1], superKey_items.toggleDND[2])
		hs.alert.show("勿扰模式切换成功",0.5)
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'D', '暗夜模式切换', function()
        toggleDarkMode()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind('', 'F', '开启专注模式', function()
        enableFocuseMode()
        -- hs.window.highlight.toggleIsolate(true)
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
    skmodal:bind('', 'C', 'caffeineMode', function()
        togglecaffeineMode()
		spoon.ModalMgr:deactivate({"SuperKey"})
    end)
	skmodal:bind('', 'E', 'eject所有DMG磁盘', function()
        ejectAllDMG()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'K', '强杀应用', function()
        forceKillCurApp()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'L', '锁屏', function()
		hs.eventtap.keyStroke({'Cmd', 'Ctrl'}, 'Q')
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'R', '重启', function()
        restartMac()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'J', '静音', function()
        toggleMute()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'M', '麦克风开关静音', function()
        toggleMicrophoneMute()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'P', '打开安全与隐私', function()
        openSecAndPrivacy()
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'T', '打开活动监视器', function()
        hs.application.launchOrFocusByBundleID("com.apple.ActivityMonitor")
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
	skmodal:bind('', 'V', '粘贴密码', function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
		spoon.ModalMgr:deactivate({"SuperKey"})
	end)
    skmodal:bind({"Shift"}, 'U', '一键升级brew', function()
        oneKeyUpgradeBrews()
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
	skmodal:bind({"Shift"}, 'H', 'MouseHighlight', function()
        -- mouseHighlight()
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