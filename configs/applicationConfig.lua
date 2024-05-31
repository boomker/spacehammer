---@diagnostic disable: lowercase-global

-- prefix：表示快捷键前缀，可选值：Ctrl、Option、Shift, Cmd
-- key：可选值 [A-Z]、[1-9]、Left、Right、Up、Down、-、=、/
-- message: 提示信息
-- name: 应用名称
-- bundleId: App唯一标识ID
-- initWindowLayout: App窗口初始(每次启动后)位置和大小
-- alwaysWindowLayout: App窗口开启全局 HS 快捷键切换后自动调整布局, 没有性能影响, 无卡顿
-- anytimeAdjustWindowLayout: App窗口开启全局任意方式切换后自动调整布局, 有一定程度性能下降!
-- onPrimaryScreen: 窗口排列位置在主显示器屏幕上
-- onBackupScreen:  窗口排列位置在副显示器屏幕上

require("configs.baseConfig")
require("configs.windowConfig")

applications = {
    {
        prefix = HyperKey,
        key = "L",
        message = "VSCode",
        bundleId = "com.microsoft.VSCode", -- 支持 App bundleID
        -- alwaysWindowLayout = window_grids.fullScreen,
        -- anytimeAdjustWindowLayout = true,
        onPrimaryScreen = true,
    },
    {
        prefix = HyperKey,
        key = "V",
        message = "neovide",
        name = { "neovide", "nvide", "goneovim" }, -- 支持多 AppName
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
        onPrimaryScreen = false,
    },
    {
        prefix = HyperKey,
        key = "O",
        message = "Obsidian",
        name = { "obsidian", "typora" }, -- 支持 APP 名称
        -- initWindowLayout = grid.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "A",
        message = "ApiPost",
        name = { "apipost", "apifox" }, -- 支持 App 名称模糊匹配(ApiPost7)
    },
    {
        prefix = HyperKey,
        key = "U",
        message = "FDM",
        name = { "fdm", "Folx" }, -- 支持 APP 名称简写
        -- name = "Free Download Manager",
        -- initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.centeredMedium,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "I",
        message = "terminal",
        name = { "Alacritty", "iTerm", "iTerm2", "warp" },
        -- bundleId = "com.googlecode.iterm2",
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "F",
        message = "Finder",
        -- bundleId = "com.cocoatech.PathFinder",
        name = { "ForkLift", "Finder", "PathFinder" },
        -- initWindowLayout = window_grids.centeredMedium,
        -- alwaysWindowLayout = window_grids.centerHorizontal,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "M",
        message = "Foxmail",
        -- bundleId = "com.tencent.Foxmail",
        name = { "Outlook", "Foxmail" },
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "B",
        message = "firefox",
        bundleId = "org.mozilla.firefox",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "K",
        message = "browser",
        name = { "Microsoft Edge", "Google Chrome", "Arc" },
        -- bundleId = "com.microsoft.edgemac",
        onBackupScreen = true,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "D",
        message = "DBeaver",
        name = { "dbeaver", "DBeaverEE", "DataGrip" },
    },
    {
        prefix = HyperKey,
        key = "E",
        message = "Excel",
        name = { "Excel", "word", "wps" },
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
        onPrimaryScreen = true,
        alwaysWindowLayout = window_grids.centeredMedium,
    },
    {
        prefix = HyperKey,
        key = "8",
        message = "NeteaseMusic",
        bundleId = "com.netease.163music",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
}
