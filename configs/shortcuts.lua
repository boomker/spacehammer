---@diagnostic disable: lowercase-global

--[[
███████╗██████╗  █████╗  ██████╗███████╗██╗  ██╗ █████╗ ███╗   ███╗███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║  ██║██╔══██╗████╗ ████║████╗ ████║██╔════╝██╔══██╗
███████╗██████╔╝███████║██║     █████╗  ███████║███████║██╔████╔██║██╔████╔██║█████╗  ██████╔╝
╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝  ██╔══██║██╔══██║██║╚██╔╝██║██║╚██╔╝██║██╔══╝  ██╔══██╗
███████║██║     ██║  ██║╚██████╗███████╗██║  ██║██║  ██║██║ ╚═╝ ██║██║ ╚═╝ ██║███████╗██║  ██║
╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
--]]

-- 配置版本号
shortcut_config = {
    version = 3.0,
}

require("configs.baseConfig")

-- HyperKey = { "Ctrl", "Option", "Shift" }
-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift, Cmd
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message: 提示信息
-- name: 应用名称
-- bundleId: App唯一标识ID
-- func: 要执行的函数
-- action: 要执行的动作
-- direction: 上下左右方向
-- location: 窗口位置
-- tag: 窗口管理模式
-- layout: 窗口布局
-- initWindowLayout: App窗口初始(每次启动后)位置和大小
-- alwaysWindowLayout: App窗口开启全局 HS 快捷键切换后自动调整布局, 没有性能影响, 无卡顿
-- anytimeAdjustWindowLayout: App窗口开启全局任意方式切换后自动调整布局, 有一定程度性能下降!
-- onPrimaryScreen: 窗口排列位置在主显示器屏幕上
-- inputmethodId: 输入法唯一标示ID, 即对应输入法 App 的 BundleId

-- window管理快捷键配置
-- configs/winmanShortcuts.lua

-- 应用切换快捷键配置
-- configs/applicationConfig.lua

-- HyperKey 按键自定义映射
-- configs/remapingShortcuts.lua

-- 剪贴板工具
clipBoardTools = { HyperKey, "C" }

-- SuperSKey 配置
superKey_toggle = { HyperKey, "S" }
superKey_items = {
    -- S: 弹出当前 APP 所有快捷键列表面板
    -- H: 查看(canvas 浮层弹出)本项目所有快捷键配置
    bartenderMenuSearch = { { "cmd", "alt", "ctrl" }, "6" },
    bobOCR = { { "cmd", "alt", "ctrl" }, "7" },
    toggleDND = { { "cmd", "alt", "ctrl" }, "\\" },
    -- 可选填写代理服务器配置
    httpProxy = "http://127.0.0.1:1087",
    favoriteBluetoothName = "小爱音箱-4099",
}

-- 表情包搜索配置
-- emoji_search = { prefix = HyperKey, key = "4", message = "Search emoji" }

-- JSON 格式化
json_formater = { prefix = HyperKey, key = "T", message = "JSON 格式化" }

-- 当选中某窗口按下 ctrl+command+alt+. 时会显示应用的路径等信息
hs.hotkey.bind({ "ctrl", "cmd", "alt" }, ".", function()
    hs.alert.show(
        "App path:    "
            .. hs.window.focusedWindow():application():path()
            .. "\n"
            .. "App name:      "
            .. hs.window.focusedWindow():application():name()
            .. "\n"
            .. "App bundleId:  "
            .. hs.window.focusedWindow():application():bundleID()
            .. "\n"
            .. "IM source id:  "
            .. hs.keycodes.currentSourceID()
    )
end)

-- 快捷显示 Hammerspoon 控制台
----------------------------------------------------------------------------------------------------
hsconsole_keys = hsconsole_keys or { "alt", "Z" }
if string.len(hsconsole_keys[2]) > 0 then
    hs.hotkey.bind(hsconsole_keys[1], hsconsole_keys[2], "打开 Hammerspoon 控制台", function()
        hs.toggleConsole()
        hs.application.launchOrFocusByBundleID("org.hammerspoon.Hammerspoon")
    end)
end

-- 快捷显示 重载 Hammerspoon 配置
----------------------------------------------------------------------------------------------------
hsreload_keys = hsreload_keys or { { "cmd", "alt", "ctrl" }, "Z" }
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "重新加载配置", function()
        -- clear all settings data
        for _, v in ipairs(hs.settings.getKeys()) do
            hs.settings.clear(v)
        end
        hs.reload()
    end)

    hs.alert.show("配置文件已经重新加载")
end
