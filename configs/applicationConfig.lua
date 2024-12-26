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
        key = "C",
        message = "Code Editor",
        -- bundleId = "com.microsoft.VSCode", -- 支持 App bundleID
        names = { "Cursor", "Visual Studio Code", "Xcode" },
        alwaysWindowLayout = window_grids.fullScreen,
        -- anytimeAdjustWindowLayout = true,
        onPrimaryScreen = true,
    },
    {
        prefix = HyperKey,
        key = "V",
        message = "Neovim",
        names = { "neovide", "nvide", "goneovim" }, -- 支持多 AppName
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
        onPrimaryScreen = false,
    },
    {
        prefix = HyperKey,
        key = "M",
        message = "markdown",
        names = { "obsidian", "typora" }, -- 支持 APP 名称
        initWindowLayout = window_grids.fullScreen,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "T",
        message = "Terminal",
        names = { "Terminal", "Alacritty", "Kitty", "wezterm", "iTerm", "Warp" },
        initWindowLayout = window_grids.fullScreen,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "O",
        message = "OFFICE",
        names = { "Excel", "ONLYOFFICE", "WPS" },
    },
    {
        prefix = HyperKey,
        key = "A",
        message = "ApiPost",
        names = { "Apipost", "Apifox" }, -- 支持 App 名称模糊匹配(ApiPost7)
    },
    {
        prefix = HyperKey,
        key = "N",
        message = "AI-ChatBox",
        names = { "Cherry Studio", "NextChat", "ChatBox", "BoltAI" },
    },
    {
        prefix = HyperKey,
        key = "U",
        message = "Update",
        names = { "Latest", "Applite", "App Store" },
        anytimeAdjustWindowLayout = true,
        initWindowLayout = window_grids.centeredMedium,
    },
    {
        prefix = HyperKey,
        key = "X",
        message = "FDM",
        names = { "fdm", "Folx" }, -- 支持 APP 名称简写
        alwaysWindowLayout = window_grids.centeredMedium,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "F",
        message = "Finder",
        names = { "访达", "QSpace Pro", "Path Finder" },
    },
    {
        prefix = HyperKey,
        key = "E",
        message = "email",
        names = { "Airmail", "Outlook", "Foxmail" },
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "R",
        message = "RSS",
        names = { "NetNewsWire", "Follow", "Feeds" },
    },
    {
        prefix = HyperKey,
        key = "P",
        message = "PDF, BDPan",
        names = { "PDF Reader Pro", "百度网盘" },
        anytimeAdjustWindowLayout = true,
        alwaysWindowLayout = window_grids.fullScreen,
        initWindowLayout = window_grids.centeredMedium,
    },
    {
        prefix = HyperKey,
        key = "B",
        message = "Backup Browser",
        names = { "Firefox", "Zen Browser", "safari" },
        onBackupScreen = true,
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "K",
        message = "Browser",
        names = { "Arc", "Microsoft Edge", "Google Chrome" },
        onBackupScreen = true,
        alwaysWindowLayout = window_grids.fullScreen,
    },
    {
        prefix = HyperKey,
        key = "D",
        message = "DBeaver",
        names = { "DBeaverUltimate", "Navicat Premium", "DataGrip" },
    },
    {
        prefix = HyperKey,
        key = "8",
        message = "Telegram",
        names = { "Telegram Desktop" },
    },
    {
        prefix = HyperKey,
        key = "Q",
        message = "QQ",
        bundleId = "com.tencent.qq",
    },
    {
        prefix = HyperKey,
        key = "i",
        message = "WeChat",
        names = { "WeChat", "Wexin" },
        onPrimaryScreen = true,
        alwaysWindowLayout = window_grids.centeredMedium,
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
        message = "Music",
        names = { "NeteaseMusic", "Music", "Spotify" },
        anytimeAdjustWindowLayout = true,
        alwaysWindowLayout = window_grids.fullScreen,
        initWindowLayout = window_grids.centeredMedium,
    },
}
