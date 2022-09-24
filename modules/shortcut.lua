-- 快捷键配置版本号
shortcut_config = {
    version = 1.0
}

-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message 表示提示信息
-- func 表示函数
-- location 表示窗口位置

-- 窗口管理快捷键配置
winman_toggle = {{"Ctrl", "Option", "Shift"}, "W"}
winman_keys = {

    -- quit
    {prefix = {}, key = "Q", message = "Quit WinMan"},
    -- 左半屏
    {prefix = {}, key = "H", message = "Left Half",  func = "moveAndResize", location = "halfleft"},
    -- 右半屏
    {prefix = {}, key = "L", message = "Right Half", func = "moveAndResize", location = "halfright"},
    -- 上半屏
    {prefix = {}, key = "K", message = "Up Half",    func = "moveAndResize", location = "halfup"},
    -- 下半屏
    {prefix = {}, key = "J", message = "Down Half",  func = "moveAndResize", location = "halfdown"},

    {prefix = {}, key = "Y", message = "屏幕左上角",  func = "moveAndResize", location = "cornerNW"},
    {prefix = {}, key = "U", message = "屏幕右上角",  func = "moveAndResize", location = "cornerNE"},
    {prefix = {}, key = "I", message = "屏幕左下角",  func = "moveAndResize", location = "cornerSW"},
    {prefix = {}, key = "O", message = "屏幕右下角",  func = "moveAndResize", location = "cornerSE"},
    {prefix = {}, key = "Z", message = "全屏",       func = "moveAndResize", location = "fullscreen"},
    {prefix = {}, key = "M", message = "最大化",     func = "moveAndResize", location = "max"},
    {prefix = {}, key = "C", message = "居中",       func = "moveAndResize", location = "center"},

    {prefix = {}, key = "E", message = "窗口移至左边屏幕", func = "wMoveToScreen", location = "left"},
    {prefix = {}, key = "T", message = "窗口移至上边屏幕", func = "wMoveToScreen", location = "up"},
    {prefix = {}, key = "B", message = "窗口移动下边屏幕", func = "wMoveToScreen", location = "down"},
    {prefix = {}, key = "N", message = "窗口移至右边屏幕", func = "wMoveToScreen", location = "right"},

    {prefix = {}, key = "S", message = "窗口移至上一个Space", func = "moveToSpace", location = "PS"},
    {prefix = {}, key = "D", message = "窗口移至下一个Space", func = "moveToSpace", location = "NS"},

    {prefix = {}, key = "F", message = "平铺窗口", func = "flattenWindow", location = ""},
    {prefix = {}, key = "G", message = "窗口网格布局", func = "gridWindow", location = ""},
    {prefix = {}, key = "R", message = "窗口布局循环切换", func = "rotateLayout", location = ""},

    {prefix = {}, key = "X", message = "killSameAppAllWindow", func = "killSameAppAllWindow", location = ""},
    {prefix = {}, key = "V", message = "closeSameAppOtherWindows", func = "closeSameAppOtherWindows", location = ""}
}

-- 应用切换快捷键配置
applications = {
    {prefix = {"Ctrl", "Option", "Shift"}, key = "L", message="VSCode", bundleId="com.microsoft.VSCode"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "I", message="iTerm2", bundleId="com.googlecode.iterm2"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "F", message="Finder", bundleId="com.cocoatech.PathFinder"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "B", message="firefox", bundleId="org.mozilla.firefox"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "K", message="Chrome", bundleId="com.google.Chrome"},
    -- {prefix = {"Ctrl", "Option", "Shift"}, key = "W", message="WizNote", bundleId="cn.wiznote.desktop"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "U", message="FDM", bundleId="org.freedownloadmanager.fdm6"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "Q", message="QQ", bundleId="com.tencent.qq"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "0", message="WeWork", bundleId="com.tencent.WeWorkMac"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "9", message="WeChat", bundleId="com.tencent.xinWeChat"},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "8", message="163music", bundleId="com.netease.163music"}
}

remapkeys = {
    -- trigger target combination key
    {prefix = {"Ctrl", "Option", "Shift"}, key = "\\", message="WindowSwitch", targetKey={{"cmd"}, "`"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "J", message="AppSwitch", targetKey={{"cmd"}, "tab"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "Y", message="EudicLightPeek", targetKey={{"cmd", "alt", "ctrl"}, "L"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "M", message="Bartender", targetKey={{"cmd", "alt", "ctrl"}, "6"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "O", message="BobOCR", targetKey={{"cmd", "alt", "ctrl"}, "7"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "N", message="Snipaste", targetKey={{"cmd", "alt", "ctrl"}, "0"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "P", message="Snipaste", targetKey={{"cmd", "alt", "ctrl"}, "9"}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "[", message="NextSpace", targetKey={{"shift", "alt", "ctrl"}, "["}},
    {prefix = {"Ctrl", "Option", "Shift"}, key = "]", message="PreSpace", targetKey={{"shift", "alt", "ctrl"}, "]"}},

    -- trigger function
    {prefix = {"Ctrl", "Option", "Shift"}, key = "D", message="ShowDesktop", targetFunc="toggleShowDesktop"}
    -- {prefix = {"Ctrl", "Option", "Shift"}, key = "T", message="gotoSpace", targetFunc="goToSpace"}
}

-- 输入法切换快捷键配置
input_methods = {
    abc = {prefix = {"Option"}, key = "J", message="ABC"},
    -- chinese = {prefix = {"Option"}, key = "K", message="简体拼音"}, 
    -- japanese = {prefix = {"Option"}, key = "L", message="Hiragana"}
}

-- 表情包搜索快捷键配置
emoji_search = { prefix = { "Ctrl", "Option", "Shift" }, key = "E" }

-- 密码粘贴快捷键配置
password_paste = {
    prefix = {
        "Ctrl", "Command"
    },
    key = "V", 
    message = "Password Paste"
}

-- 快捷键查看面板快捷键配置
hscheats_keys = {{"Ctrl", "Option", "Shift"}, "S"}

-- hotkey = {
--     prefix = {
--         "Option"
--     },
--     key = "A"
-- }
