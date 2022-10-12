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

require "configs.baseConfig"


-- HyperKey = { "Ctrl", "Option", "Shift" }
-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift, Cmd
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message: 提示信息
-- func: 要执行的函数
-- action: 要执行的动作
-- direction: 上下左右方向
-- location: 窗口位置
-- initWindowLayout: App窗口初始(每次启动后)位置和大小
-- alwaysWindowLayout: App窗口开启全局 HS 快捷键切换后自动调整布局, 没有性能影响, 无卡顿
-- anytimeAdjustWindowLayout: App窗口开启全局任意方式切换后自动调整布局, 有一定程度性能下降! 
-- onPrimaryScreen: 窗口排列位置在主显示器屏幕上
-- bundleId: App唯一标识ID
-- inputmethodId: 输入法唯一标示ID, 即对应输入法 App 的 BundleId

-- window管理快捷键配置
-- configs/winmanShortcuts.lua

-- 应用切换快捷键配置
-- configs/applicationConfig.lua

-- HyperKey 按键自定义映射
-- configs/remapingShortcuts.lua

-- 剪贴板工具
clipBoardTools = { HyperKey, "V" }

-- SuperSKey 配置
superKey_toggle = { HyperKey, "S" }
superKey_items = {
    -- S: 弹出当前 APP 所有快捷键列表面板
    -- H: 查看(canvas 浮层弹出)本项目所有快捷键配置
    -- hshelp_keys = { prefix = { "Option" }, key = "S" }
    bartenderMenuSearch = { { "cmd", "alt", "ctrl" }, "6" },
    bobOCR = { { "cmd", "alt", "ctrl" }, "7" },
    toggleDND = { { "cmd", "alt", "ctrl" }, "\\" },
    favoriteBluetoothName = "小爱音箱-4099",
    -- 可选填写代理服务器配置
    httpProxy = "http://127.0.0.1:7890",
}

-- ===== 输入法自动切换和手动切换快捷键配置 ===== --
input_method_config = {

    input_methods = {
        -- 输入法 BundleId 配置
        -- sogouId = 'com.sogou.inputmethod.sogou.pinyin',
        -- abcId = 'com.apple.keylayout.ABC',
        -- shuangpinId = 'com.apple.inputmethod.SCIM.Shuangpin',

        -- 以下键名(abc, chinese)不能改
        abc = {
            prefix = HyperKey,
            key = "X",
            message = "切换到英文输入法",
            inputmethodId = "com.apple.keylayout.ABC",
        },
        chinese = {
            prefix = HyperKey,
            key = "C",
            message = "切换到搜狗输入法",
            inputmethodId = "com.sogou.inputmethod.sogou.pinyin",
        },
        -- chinese = { prefix = HyperKey, key = "D", message = "双拼", inputmethodId = shuangpinId },
    },

    --  以下 App 聚焦后自动切换到目标输入法, 需要配置目标应用名称或应用的 BundleId
    abc_apps = {
        -- "com.microsoft.VSCode", -- VSCode的应用名为"Code"
        -- 从 CLI 启动的APP窗口程序, 如若是别名, 需将别名添加到下面
        "Code",
        "PyCharm",
        "com.jetbrains.intellij",
        "Terminal",
        "com.googlecode.iterm2",
        "com.neovide.neovide",
        "nvide",
        "com.kapeli.dashdoc",
        "com.runningwithcrayons.Alfred",
        "Raycast",
    },

    chinese_apps = {
        -- "com.tencent.xinWeChat", -- 这是微信的 BundleId , 应用名称为"WeChat", 应用标题为 "微信", 均支持
        "微信",
        "企业微信",
        "QQ",
        "网易云音乐",
        "Typora",
        'Obsidian',
        "com.yinxiang.Mac",
    },
}

-- 表情包搜索配置
emoji_search = { prefix = HyperKey, key = "E", message = "Search emoji" }

-- JSON 格式化
json_formater = { prefix = HyperKey, key = "T", message = "JSON 格式化" }

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
hsreload_keys = hsreload_keys or { { "cmd", "shift", "ctrl" }, "Z" }
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "重新加载配置", function()
        hs.reload()
    end)

    hs.alert.show("配置文件已经重新加载")
end
