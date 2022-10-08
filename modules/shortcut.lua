---@diagnostic disable: lowercase-global
-- 快捷键配置版本号
shortcut_config = {
    version = 1.1,
}

hs.alert.defaultStyle.atScreenEdge = 2
hs.alert.defaultStyle.textSize = 16

HyperKey = { "Ctrl", "Option", "Shift" }
-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift, Cmd
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message: 提示信息
-- func: 函数
-- location: 窗口位置
-- direction: 上下左右方向
-- initWindowLayout: App窗口初始(每次启动)位置和大小
-- alwaysWindowLayout: App窗口全局位置和大小
-- onPrimaryScreen: 窗口排列位置在主显示器屏幕上
-- bundleId: App唯一标识ID
-- inputmethodId: 输入法唯一标示ID, 即对应输入法 App 的 BundleId

-- === 窗口管理配置 === --
winman_toggle = { HyperKey, "W" }
winGridMan_toggle = { HyperKey, "G" }
-- hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.grid.setGrid("16x12") -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0 -- disable animations

winman_mode = "persistent" -- 可选值[persistent]: 持久模式, 留空即为非持久模式
window_grids = {
    topHalf = "0,0 16x6",
    topThird = "0,0 16x4",
    topTwoThirds = "0,0 16x8",

    rightHalf = "8,0 8x12",
    rightThird = "11,0 5x12",
    rightTwoThirds = "2,0 14x12",

    bottomHalf = "0,6 16x6",
    bottomThird = "0,7 16x5",
    bottomTwoThirds = "0,2 16x10",

    leftHalf = "0,0 8x12",
    leftThird = "0,0 4x12",
    leftTwoThirds = "0,0 14x12",

    topLeft = "0,0 8x6",
    topRight = "8,0 8x6",
    bottomRight = "8,6 8x6",
    bottomLeft = "0,6 8x6",

    fullScreen = "0,0 16x12",
    centeredBig = "1,1 14x10",
    centeredMedium = "2,1 12x10",
    centerHorizontal = "1,0 14x12",
    centerVertical = "0,2 16x8",
}
window_grid_groups = {
    LeftGrid = {
        window_grids.leftHalf,
        window_grids.leftThird,
        window_grids.leftTwoThirds,
    },
    RightGrid = {
        window_grids.rightHalf,
        window_grids.rightThird,
        window_grids.rightTwoThirds,
    },
    TopGrid = {
        window_grids.topHalf,
        window_grids.topThird,
        window_grids.topTwoThirds,
    },
    BottomGrid = {
        window_grids.bottomHalf,
        window_grids.bottomThird,
        window_grids.bottomTwoThirds,
    },
    CenterGrid = {
        window_grids.fullScreen,
        window_grids.centeredBig,
        window_grids.centeredMedium,
        window_grids.centerHorizontal,
        window_grids.centerVertical,
    },
    cornerGrid = {
        window_grids.topLeft,
        window_grids.topRight,
        window_grids.bottomRight,
        window_grids.bottomLeft,
    },
}
window_group_layouts = {
    -- 缺点: 只能将已经激活的窗口平铺
    -- ToDo: 激活聚焦配置中对应的 App 窗口, 并置于最前面
    chrome_iterm2 = {
        "CCCCCCCCCCCCVVVVVVVVVVVV",
        "",
        "C Google Chrome",
        "V Code",
    },
    finder_iTerm2 = {
        -- "fffffffffffffiiiiiiiiiii",

        -- "ffffffffffffffffff",
        -- "iiiiiiiiiiiiiiiiii",

        "fffffffffff iiiiiiiiiii",
        "", -- 不能省略
        "f 访达", -- 窗口 Title
        "i iTerm2",
    },
}
winman_keys = {
    { -- quit
        prefix = {},
        key = "Q",
        message = "Quit WinMan",
    },
    { -- 左半屏
        prefix = {},
        -- key = "Left",
        key = "H",
        message = "Left Half",
        func = "moveAndResize",
        location = "halfleft",
        tag = "origin",
    },
    { -- 右半屏
        prefix = {},
        key = "L",
        message = "Right Half",
        func = "moveAndResize",
        location = "halfright",
        tag = "origin",
    },
    { -- 上半屏
        prefix = {},
        key = "K",
        message = "Up Half",
        func = "moveAndResize",
        location = "halfup",
        tag = "origin",
    },
    { -- 下半屏
        prefix = {},
        key = "J",
        message = "Down Half",
        func = "moveAndResize",
        location = "halfdown",
        tag = "origin",
    },
    -- 窗口平移至当前屏幕四个角落, 不会改变窗口原来尺寸
    {
        prefix = {},
        key = "Y",
        message = "窗口移到屏幕左上角 ↖️ ",
        func = "moveAndResize",
        location = "screenCornerNW",
        tag = "origin",
    },
    {
        prefix = {},
        key = "U",
        message = "窗口移到屏幕右上角 ↗️ ",
        func = "moveAndResize",
        location = "screenCornerNE",
        tag = "origin",
    },
    {
        prefix = {},
        key = "I",
        message = "窗口移到屏幕左下角 ↙️ ",
        func = "moveAndResize",
        location = "screenCornerSW",
        tag = "origin",
    },
    {
        prefix = {},
        key = "O",
        message = "窗口移到屏幕右下角 ↘️ ",
        func = "moveAndResize",
        location = "screenCornerSE",
        tag = "origin",
    },
    {
        prefix = {},
        key = "P",
        message = "开关全屏",
        func = "moveAndResize",
        location = "fullscreen",
        tag = "origin",
    },
    {
        prefix = {},
        key = "M",
        message = "最大化",
        func = "moveAndResize",
        location = "max",
        tag = "origin",
    },
    {
        prefix = {},
        key = "C",
        message = "窗口移到屏幕正中",
        func = "moveAndResize",
        location = "center",
        tag = "origin",
    },
    {
        prefix = {},
        key = "Z",
        message = "撤销窗口操作",
        func = "undo",
        location = "",
        tag = "origin",
    },
    -- 窗口平移至当前屏幕左右顶底四边, 不会改变窗口原来尺寸
    {
        prefix = { "Ctrl", "Shift" },
        key = "H",
        message = "窗口移到屏幕左边",
        func = "moveAndResize",
        location = "screenLB",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "J",
        message = "窗口移到屏幕底边",
        func = "moveAndResize",
        location = "screenDB",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "K",
        message = "窗口移到屏幕顶边",
        func = "moveAndResize",
        location = "screenUB",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "L",
        message = "窗口移到屏幕右边",
        func = "moveAndResize",
        location = "screenRB",
        tag = "origin",
    },
    -- 改变原来窗口尺寸至 1/4 屏幕大小
    {
        prefix = { "Ctrl", "Shift" },
        key = "Y",
        message = "屏幕左上角 ↖️ ",
        func = "moveAndResize",
        location = "cornerNW",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "U",
        message = "屏幕右上角 ↗️ ",
        func = "moveAndResize",
        location = "cornerNE",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "I",
        message = "屏幕左下角 ↙️ ",
        func = "moveAndResize",
        location = "cornerSW",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "O",
        message = "屏幕右下角 ↘️ ",
        func = "moveAndResize",
        location = "cornerSE",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "E",
        message = "窗口拉伸",
        func = "moveAndResize",
        location = "expand",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "S",
        message = "窗口收缩",
        func = "moveAndResize",
        location = "shrink",
        tag = "origin",
    },
    {
        prefix = {},
        key = "left",
        message = "窗口向左收缩 ⬅️ ",
        func = "stepResize",
        direction = "left",
        tag = "origin",
    },
    {
        prefix = {},
        key = "right",
        message = "窗口向右扩展 ➡️ ",
        func = "stepResize",
        direction = "right",
        tag = "origin",
    },
    {
        prefix = { "Ctrl" },
        key = "right",
        message = "窗口向右扩展 ➡️ ",
        func = "stepResize",
        direction = "rightExpanToScreen",
        tag = "origin",
    },
    {
        prefix = { "Ctrl" },
        key = "left",
        message = "窗口向左扩展 ⬅️ ",
        func = "stepResize",
        direction = "leftExpanToScreen",
        tag = "origin",
    },
    {
        prefix = { "Ctrl" },
        key = "up",
        message = "窗口向上扩展 ⬆️ ",
        func = "stepResize",
        direction = "upExpanToScreen",
        tag = "origin",
    },
    {
        prefix = { "Ctrl" },
        key = "down",
        message = "窗口向下扩展 ⬇️ ",
        func = "stepResize",
        direction = "downExpanToScreen",
        tag = "origin",
    },
    {
        prefix = {},
        key = "up",
        message = "窗口向上收缩 ⬆️ ",
        func = "stepResize",
        direction = "up",
        tag = "origin",
    },
    {
        prefix = {},
        key = "down",
        message = "窗口向下扩展 ⬇️ ",
        func = "stepResize",
        direction = "down",
        tag = "origin",
    },
    {
        prefix = {},
        key = "E",
        message = "窗口移至左边屏幕",
        func = "wMoveToScreen",
        location = "left",
        tag = "origin",
    },
    {
        prefix = {},
        key = "T",
        message = "窗口移至上边屏幕",
        func = "wMoveToScreen",
        location = "up",
        tag = "origin",
    },
    {
        prefix = {},
        key = "B",
        message = "窗口移动下边屏幕",
        func = "wMoveToScreen",
        location = "down",
        tag = "origin",
    },
    {
        prefix = {},
        key = "N",
        message = "窗口移至右边屏幕",
        func = "wMoveToScreen",
        location = "right",
        tag = "origin",
    },
    {
        prefix = {},
        key = "S",
        message = "窗口移至上一个Space",
        func = "moveToSpace",
        direction = "left",
        -- 是否跟随窗口一起跳到新空间并聚焦
        followWindow = true,
        tag = "origin",
    },
    {
        prefix = {},
        key = "D",
        message = "窗口移至下一个Space",
        func = "moveToSpace",
        direction = "right",
        -- 'false' : 不会跟随窗口移动, 并会在当前 space 自动点击最上层的窗口以获取焦点
        followWindow = false,
        tag = "origin",
    },
    -- 对同一 APP 所有窗口
    {
        prefix = { "Ctrl", "Shift" },
        key = "F",
        message = "同一APP所有窗口平铺",
        func = "flattenWindow",
        location = "",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "G",
        message = "同一APP所有窗口网格",
        func = "gridWindow",
        location = "",
        tag = "origin",
    },
    {
        prefix = { "Ctrl", "Shift" },
        key = "R",
        message = "切换同一APP窗口布局 🔄",
        func = "rotateLayout",
        location = "",
        tag = "origin",
    },
    -- 对同一 Space 所有APP所有窗口
    {
        prefix = {},
        key = "F",
        message = "所有窗口平铺",
        func = "flattenWindowsForSpace",
        location = "",
        tag = "origin",
    },
    {
        prefix = {},
        key = "G",
        message = "所有窗口网格",
        func = "gridWindowsForSpace",
        location = "",
        tag = "origin",
    },
    {
        prefix = {},
        key = "R",
        message = "切换所有窗口布局 🔄",
        func = "rotateLayoutWindowsForSpace",
        location = "",
        tag = "origin",
    },
    {
        prefix = {},
        key = "X",
        message = "killSameAppAllWindow",
        func = "killSameAppAllWindow",
        location = "",
        tag = "origin",
    },
    {
        prefix = {},
        key = "V",
        -- message = "closeSameAppOtherWindows",
        message = "关闭同应用其他窗口",
        func = "closeSameAppOtherWindows",
        location = "",
        tag = "origin",
    },

    ------ Grid 模式键绑定配置 ------
    {
        prefix = {},
        key = "H",
        message = "窗口在屏幕左半部布局组",
        mapGridGroup = window_grid_groups.LeftGrid,
        tag = "grid",
    },
    {
        prefix = {},
        key = "L",
        message = "窗口在屏幕右半部布局组",
        mapGridGroup = window_grid_groups.RightGrid,
        tag = "grid",
    },
    {
        prefix = {},
        key = "K",
        message = "窗口在屏幕顶部布局组",
        mapGridGroup = window_grid_groups.TopGrid,
        tag = "grid",
    },
    {
        prefix = {},
        key = "J",
        message = "窗口在屏幕底部布局组",
        mapGridGroup = window_grid_groups.BottomGrid,
        tag = "grid",
    },
    {
        prefix = {},
        key = "S",
        message = "窗口在屏幕四角布局组",
        mapGridGroup = window_grid_groups.cornerGrid,
        tag = "grid",
    },
    {
        prefix = {},
        key = "C",
        message = "窗口在屏幕中心部布局组",
        mapGridGroup = window_grid_groups.CenterGrid,
        tag = "grid",
    },
}

-- 应用切换快捷键配置
applications = {
    {
        prefix = HyperKey,
        key = "L",
        message = "VSCode",
        bundleId = "com.microsoft.VSCode",
        alwaysWindowLayout = window_grids.fullScreen,
        onPrimaryScreen = true,
    },
    {
        prefix = HyperKey,
        key = "M",
        message = "Typora",
        name = "Typora",
        -- bundleId = "abnerworks.Typora"
        -- initWindowLayout = grid.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "I",
        message = "iTerm2",
        bundleId = "com.googlecode.iterm2",
        alwaysWindowLayout = window_grids.bottomTwoThirds,
    },
    {
        prefix = HyperKey,
        key = "F",
        message = "Finder",
        bundleId = "com.cocoatech.PathFinder",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.centerHorizontal,
    },
    {
        prefix = HyperKey,
        key = "A",
        message = "ApiPost",
        name = "ApiPost7",
    },
    {
        prefix = HyperKey,
        key = "B",
        message = "firefox",
        bundleId = "org.mozilla.firefox",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "K",
        message = "Chrome",
        bundleId = "com.google.Chrome",
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "D",
        message = "DBeaver",
        name = "DBeaver",
    },
    {
        prefix = HyperKey,
        key = "U",
        message = "FDM",
        name = "Free Download Manager",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "Q",
        message = "QQ",
        bundleId = "com.tencent.qq",
    },
    {
        prefix = HyperKey,
        key = "0",
        message = "WeWork",
        bundleId = "com.tencent.WeWorkMac",
    },
    {
        prefix = HyperKey,
        key = "9",
        message = "WeChat",
        bundleId = "com.tencent.xinWeChat",
        alwaysWindowLayout = window_grids.centeredMedium,
    },
    {
        prefix = HyperKey,
        key = "8",
        message = "Music",
        bundleId = "com.netease.163music",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.centeredBig,
    },
}

-- HyperKey 按键自定义映射
remapkeys = { -- trigger target combination key
    -- 将系统设置的" 切换到桌面 1 "快捷键配置如下
    switchToFirstDesktopSpaceHotKey = { { "cmd", "alt", "ctrl" }, "," },

    {
        prefix = HyperKey,
        key = ",",
        message = "切换到第一个桌面空间",
        targetKey = { { "cmd", "alt", "ctrl" }, "," },
    },
    {
        prefix = HyperKey,
        key = ".",
        message = "WindowSwitch",
        targetKey = { { "cmd" }, "`" },
    },
    {
        prefix = HyperKey,
        key = "J",
        message = "AppSwitch",
        targetKey = { { "cmd" }, "tab" },
    },
    {
        prefix = HyperKey,
        key = "Y",
        message = "EudicLightPeek",
        targetKey = { { "cmd", "alt", "ctrl" }, "L" },
    },
    {
        prefix = HyperKey,
        key = "N",
        message = "Snipaste",
        targetKey = { { "cmd", "alt", "ctrl" }, "0" },
    },
    {
        prefix = HyperKey,
        key = "P",
        message = "Snipaste",
        targetKey = { { "cmd", "alt", "ctrl" }, "9" },
    },

    -- trigger function
    {
        prefix = HyperKey,
        key = "Z",
        message = "窗口最大化",
        targetFunc = "windowMaximze",
    },
    {
        prefix = HyperKey,
        key = ";",
        message = "窗口最小化",
        targetFunc = "windowMinimize",
    },
    {
        prefix = HyperKey,
        key = "O",
        message = "winwodGroupAutoLayout",
        targetFunc = "winwodGroupAutoLayout",
    },
    {
        prefix = HyperKey,
        key = "[",
        message = "goToNextSpace",
        targetFunc = "goToNextSpace",
    },
    {
        prefix = HyperKey,
        key = "]",
        message = "goToPreSpace",
        targetFunc = "goToPreSpace",
    },
    -- 在当前桌面空间循环聚焦到每个窗口, 即便窗口被挡住也能放置最前面
    {
        prefix = HyperKey,
        key = "tab",
        message = "jumpToWindowAndFocus",
        targetFunc = "jumpToWindowAndFocus",
    },
}

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
        "com.yinxiang.Mac",
    },
}

--  caffeine 配置
caffConfig = {
    caffeine = "on",
}

-- 表情包搜索配置
emoji_search = {
    prefix = HyperKey,
    key = "E",
    message = "Search emoji",
}

-- JSON 格式化
jsonFormater = {
    prefix = HyperKey,
    key = "T",
    message = "JSON 格式化",
}

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
