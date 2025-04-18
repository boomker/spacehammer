---@diagnostic disable: lowercase-global

require("configs.baseConfig")

remapingKeys = { -- trigger target combination key
    -- 将系统设置的" 切换到桌面 1 "快捷键配置如下
    switchToFirstSpaceHotKey = { { "cmd", "alt", "ctrl" }, "1" },

    --[[ {
        prefix = HyperKey,
        key = "1",
        message = "切换到第1个桌面空间",
        targetKey = { { "cmd", "alt", "ctrl" }, "1" },
    },
    {
        prefix = HyperKey,
        key = "2",
        message = "切换到第2个桌面空间",
        targetKey = { { "cmd", "alt", "ctrl" }, "2" },
    },
    {
        prefix = HyperKey,
        key = "3",
        message = "切换到第3个桌面空间",
        targetKey = { { "cmd", "alt", "ctrl" }, "3" },
    },
    {
        prefix = HyperKey,
        key = ".",
        message = "WindowSwitch",
        targetKey = { { "cmd" }, "`" },
    }, ]]
    {
        prefix = HyperKey,
        key = "J",
        message = "AppSwitch",
        targetKey = { { "cmd", "alt", "ctrl", "shift" }, "J" },
    },
    {
        prefix = HyperKey,
        key = "H",
        message = "Raycast clipboard",
        targetKey = { { "cmd", "alt", "ctrl", "shift" }, "H" },
    },
    -- {
    --     prefix = HyperKey,
    --     key = "N",
    --     message = "PixPin",
    --     targetKey = { { "cmd", "alt", "ctrl", "shift" }, "S" },
    -- },
    -- {
    --     prefix = HyperKey,
    --     key = "B",
    --     message = "Snipaste",
    --     targetKey = { { "cmd", "alt", "ctrl", "shift" }, "P" },
    -- },

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
        key = "L",
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
        message = "轮切当前空间APP",
        targetKey = { { "ctrl", "Fn" }, "F4" },
    },
}
