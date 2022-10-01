---@diagnostic disable: lowercase-global
-- 快捷键配置版本号
shortcut_config = {
    version = 1.1
}

HyperKey = {"Ctrl", "Option", "Shift"}
-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift, Cmd
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message: 提示信息
-- func: 函数
-- location: 窗口位置
-- direction: 上下左右方向
-- bundleId: App唯一标识ID
-- inputmethodId: 输入法唯一标示ID, 即对应输入法 App 的 BundleId

-- 窗口管理快捷键配置
winman_toggle = {HyperKey, "W"}
winman_keys = {
{-- quit
    prefix = {},
    key = "Q",
    message = "Quit WinMan"
},
{ -- 左半屏
    prefix = {},
    key = "H",
    message = "Left Half",
    func = "moveAndResize",
    location = "halfleft"
},
{ -- 右半屏
    prefix = {},
    key = "L",
    message = "Right Half",
    func = "moveAndResize",
    location = "halfright"
},
{ -- 上半屏
    prefix = {},
    key = "K",
    message = "Up Half",
    func = "moveAndResize",
    location = "halfup"
},
{ -- 下半屏
    prefix = {},
    key = "J",
    message = "Down Half",
    func = "moveAndResize",
    location = "halfdown"
},
-- 窗口平移至当前屏幕四个角落, 不会改变窗口原来尺寸
{
    prefix = {},
    key = "Y",
    message = "窗口移到屏幕左上角",
    func = "moveAndResize",
    location = "screenCornerNW"
}, {
    prefix = {},
    key = "U",
    message = "窗口移到屏幕右上角",
    func = "moveAndResize",
    location = "screenCornerNE"
}, {
    prefix = {},
    key = "I",
    message = "窗口移到屏幕左下角",
    func = "moveAndResize",
    location = "screenCornerSW"
}, {
    prefix = {},
    key = "O",
    message = "窗口移到屏幕右下角",
    func = "moveAndResize",
    location = "screenCornerSE"
}, {
    prefix = {},
    key = "P",
    message = "开关全屏",
    func = "moveAndResize",
    location = "fullscreen"
}, {
    prefix = {},
    key = "M",
    message = "最大化",
    func = "moveAndResize",
    location = "max"
}, {
    prefix = {},
    key = "C",
    message = "窗口移到屏幕正中",
    func = "moveAndResize",
    location = "center"
}, {
    prefix = {},
    key = "Z",
    message = "撤销窗口操作",
    func = "undo",
    location = ""
},
-- 窗口平移至当前屏幕左右顶底四边, 不会改变窗口原来尺寸
{
    prefix = {"Ctrl", "Shift"},
    key = "H",
    message = "窗口移到屏幕左边",
    func = "moveAndResize",
    location = "screenLB"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "J",
    message = "窗口移到屏幕底边",
    func = "moveAndResize",
    location = "screenDB"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "K",
    message = "窗口移到屏幕顶边",
    func = "moveAndResize",
    location = "screenUB"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "L",
    message = "窗口移到屏幕右边",
    func = "moveAndResize",
    location = "screenRB"
},
-- 改变原来窗口尺寸至 1/4 屏幕大小
{
    prefix = {"Ctrl", "Shift"},
    key = "Y",
    message = "屏幕左上角",
    func = "moveAndResize",
    location = "cornerNW"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "U",
    message = "屏幕右上角",
    func = "moveAndResize",
    location = "cornerNE"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "I",
    message = "屏幕左下角",
    func = "moveAndResize",
    location = "cornerSW"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "O",
    message = "屏幕右下角",
    func = "moveAndResize",
    location = "cornerSE"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "E",
    message = "窗口拉伸",
    func = "moveAndResize",
    location = "expand"
}, {
    prefix = {"Ctrl", "Shift"},
    key = "S",
    message = "窗口收缩",
    func = "moveAndResize",
    location = "shrink"
}, {
    prefix = {},
    key = "E",
    message = "窗口移至左边屏幕",
    func = "wMoveToScreen",
    location = "left"
}, {
    prefix = {},
    key = "T",
    message = "窗口移至上边屏幕",
    func = "wMoveToScreen",
    location = "up"
}, {
    prefix = {},
    key = "B",
    message = "窗口移动下边屏幕",
    func = "wMoveToScreen",
    location = "down"
}, {
    prefix = {},
    key = "N",
    message = "窗口移至右边屏幕",
    func = "wMoveToScreen",
    location = "right"
}, {
    prefix = {},
    key = "S",
    message = "窗口移至上一个Space",
    func = "moveToSpace",
    direction = "left"
}, {
    prefix = {},
    key = "D",
    message = "窗口移至下一个Space",
    func = "moveToSpace",
    direction = "right"
},
-- 无法跳到下一个桌面空间
-- { prefix = {}, key = "[", message = "窗口聚焦下一个Space", func = "moveAndFocusToSpace", direction = "right" },
-- 对同一 APP 所有窗口
{
    prefix = {"Ctrl", "Shift"},
    key = "F",
    message = "APP所有窗口平铺",
    func = "flattenWindow",
    location = ""
}, {
    prefix = {"Ctrl", "Shift"},
    key = "G",
    message = "APP所有窗口网格",
    func = "gridWindow",
    location = ""
}, {
    prefix = {"Ctrl", "Shift"},
    key = "R",
    message = "切换APP窗口布局",
    func = "rotateLayout",
    location = ""
},
-- 对同一 Space 所有APP所有窗口
{
    prefix = {},
    key = "F",
    message = "所有窗口平铺",
    func = "flattenWindowsForSpace",
    location = ""
}, {
    prefix = {},
    key = "G",
    message = "所有窗口网格",
    func = "gridWindowsForSpace",
    location = ""
}, {
    prefix = {},
    key = "R",
    message = "切换所有窗口布局",
    func = "rotateLayoutWindowsForSpace",
    location = ""
}, {
    prefix = {},
    key = "X",
    message = "killSameAppAllWindow",
    func = "killSameAppAllWindow",
    location = ""
}, {
    prefix = {},
    key = "V",
    message = "closeSameAppOtherWindows",
    func = "closeSameAppOtherWindows",
    location = ""
}}

-- 应用切换快捷键配置
applications = {{
    prefix = HyperKey,
    key = "L",
    message = "VSCode",
    bundleId = "com.microsoft.VSCode"
}, {
    prefix = HyperKey,
    key = "I",
    message = "iTerm2",
    bundleId = "com.googlecode.iterm2"
}, {
    prefix = HyperKey,
    key = "F",
    message = "Finder",
    bundleId = "com.cocoatech.PathFinder"
}, {
    prefix = HyperKey,
    key = "A",
    message = "ApiPost",
    name = "ApiPost7"
}, {
    prefix = HyperKey,
    key = "B",
    message = "firefox",
    bundleId = "org.mozilla.firefox"
}, {
    prefix = HyperKey,
    key = "K",
    message = "Chrome",
    bundleId = "com.google.Chrome"
}, {
    prefix = HyperKey,
    key = "D",
    message = "DBeaver",
    name = "DBeaver"
}, {
    prefix = HyperKey,
    key = "U",
    message = "FDM",
    name = "Free Download Manager"
}, {
    prefix = HyperKey,
    key = "Q",
    message = "QQ",
    bundleId = "com.tencent.qq"
}, {
    prefix = HyperKey,
    key = "0",
    message = "WeWork",
    bundleId = "com.tencent.WeWorkMac"
}, {
    prefix = HyperKey,
    key = "9",
    message = "WeChat",
    bundleId = "com.tencent.xinWeChat"
}, {
    prefix = HyperKey,
    key = "8",
    message = "Music",
    bundleId = "com.netease.163music"
}}

remapkeys = { -- trigger target combination key
{
    prefix = HyperKey,
    key = ".",
    message = "WindowSwitch",
    targetKey = {{"cmd"}, "`"}
}, {
    prefix = HyperKey,
    key = "J",
    message = "AppSwitch",
    targetKey = {{"cmd"}, "tab"}
}, {
    prefix = HyperKey,
    key = "Y",
    message = "EudicLightPeek",
    targetKey = {{"cmd", "alt", "ctrl"}, "L"}
}, {
    prefix = HyperKey,
    key = "M",
    message = "Bartender",
    targetKey = {{"cmd", "alt", "ctrl"}, "6"}
}, {
    prefix = HyperKey,
    key = "O",
    message = "BobOCR",
    targetKey = {{"cmd", "alt", "ctrl"}, "7"}
}, {
    prefix = HyperKey,
    key = "N",
    message = "Snipaste",
    targetKey = {{"cmd", "alt", "ctrl"}, "0"}
}, {
    prefix = HyperKey,
    key = "P",
    message = "Snipaste",
    targetKey = {{"cmd", "alt", "ctrl"}, "9"}
},
-- trigger function
{
    prefix = HyperKey,
    key = "Z",
    message = "ShowDesktop",
    targetFunc = "toggleShowDesktop"
}, {
    prefix = HyperKey,
    key = "[",
    message = "goToNextSpace",
    targetFunc = "goToNextSpace"
}, {
    prefix = HyperKey,
    key = "]",
    message = "goToPreSpace",
    targetFunc = "goToPreSpace"
},
-- 在当前桌面空间循环聚焦到每个窗口, 即便窗口被挡住也能放置最前面
{
    prefix = HyperKey,
    key = "tab",
    message = "jumpToWindowAndFocus",
    targetFunc = "jumpToWindowAndFocus"
}}

-- 将系统设置的"切换到桌面 1"快捷键配置如下
firstDesktopSpaceHotKey = {{"cmd", "alt", "ctrl"}, ","}

-- 弹出剪贴板工具
hsclipsM_keys = {HyperKey, "V"}

-- 弹出当前 APP 所有快捷键列表面板
hscheats_keys = {HyperKey, "S"}

-- ===== 输入法自动切换和手动切换快捷键配置 ===== --
-- 输入法 BundleId 配置
sogouId = 'com.sogou.inputmethod.sogou.pinyin'
abcId = 'com.apple.keylayout.ABC'
shuangpinId = 'com.apple.inputmethod.SCIM.Shuangpin'

input_method_config = {

    input_methods = {
        -- 以下键名(abc, chinese)不能改
        abc = {
            prefix = HyperKey,
            key = "X",
            message = "ABC",
            inputmethodId = abcId
        },
        chinese = {
            prefix = HyperKey,
            key = "C",
            message = "搜狗",
            inputmethodId = sogouId
        }
        -- chinese = { prefix = HyperKey, key = "D", message = "双拼", inputmethodId = shuangpinId },
    },

    --  以下 App 聚焦后自动切换到目标输入法, 需要配置目标应用名称或应用的 BundleId
    abc_apps = {
		-- "com.microsoft.VSCode", -- VSCode的应用名为"Code"
    "Code", "PyCharm", "Terminal", "com.googlecode.iterm2", "com.neovide.neovide"},

    chinese_apps = {
		-- "com.tencent.xinWeChat", -- 微信的应用名称为"WeChat"
    "WeChat", "com.tencent.WeWorkMac", "com.netease.163music"}

}

-- 表情包搜索快捷键配置
emoji_search = {
    prefix = HyperKey,
    key = "E",
    message = "Search emoji"
}

-- JSON 格式化快捷键
jsonFormatKey = {
    prefix = HyperKey,
    key = "T",
    message = "JSON 格式化"
}

-- 密码粘贴快捷键配置
password_paste = {
    prefix = {"Ctrl", "Command"},
    key = "V",
    message = "Password Paste"
}

-- 快捷键查看面板快捷键配置
-- hotkey = {
--     prefix = {
--         "Option"
--     },
--     key = "A"
-- }
