---@diagnostic disable: lowercase-global

require "configs.baseConfig"
require "configs.windowConfig"


applications = {
    {
        prefix = HyperKey,
        key = "L",
        message = "VSCode",
        bundleId = "com.microsoft.VSCode",
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
        onPrimaryScreen = true,
    },
    {
        prefix = HyperKey,
        key = "O",
        message = "Obsidian",
        name = "obsidian",
        -- initWindowLayout = grid.centeredMedium,
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "I",
        message = "iTerm2",
        bundleId = "com.googlecode.iterm2",
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "F",
        message = "Finder",
        bundleId = "com.cocoatech.PathFinder",
        initWindowLayout = window_grids.centeredMedium,
        alwaysWindowLayout = window_grids.centerHorizontal,
        anytimeAdjustWindowLayout = true,
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
        anytimeAdjustWindowLayout = true,
    },
    {
        prefix = HyperKey,
        key = "K",
        message = "Chrome",
        bundleId = "com.google.Chrome",
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
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
        anytimeAdjustWindowLayout = true,
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
        alwaysWindowLayout = window_grids.fullScreen,
        anytimeAdjustWindowLayout = true,
    },
}