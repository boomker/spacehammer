---@diagnostic disable: lowercase-global

require "configs.baseConfig"

remapingKeys = { -- trigger target combination key
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
        key = "H",
        message = "Raycast clipboard",
        targetKey = { { "cmd", "alt", "ctrl" }, "H" },
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
        key = "X",
        message = "MenuChooser",
        targetFunc = "menuchooser",
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
