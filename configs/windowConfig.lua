---@diagnostic disable: lowercase-global

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


-- === 窗口管理配置 === --
winman_toggle = { HyperKey, "W" }
winGridMan_toggle = { HyperKey, "G" }
-- hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.grid.setGrid("16x12") -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0 -- disable animations

winman_mode = "persistent" -- 可选值[persistent]: 持久模式, 留空即为非持久模式
winman_dynamicAdjustWindowLayout = false -- 窗口动态(聚焦后立即)调整布局全局总开关, 开启后, 可能性能下降

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
    HalfScreenGrid = {
        window_grids.leftHalf,
        window_grids.rightHalf,
        window_grids.topHalf,
        window_grids.bottomHalf
    },
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