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
-- tag: 窗口管理模式
-- layout: 窗口布局


-- === 窗口管理配置 === --
winman_toggle = { HyperKey, "W" }
winGridMan_toggle = { HyperKey, "G" }
hs.grid.setGrid("16x12") -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
-- hs.grid.GRIDWIDTH = 10
-- hs.grid.GRIDHEIGHT = 3
GridWidth = 16
GridHeight = 12
reGridWidth = 10
reGridHeight = 3

hs.grid.ui.textSize = 30
hs.grid.ui.highlightColor = {0, 1, 0, 0.3}
hs.grid.ui.highlightStrokeColor = {0, 1, 0, 0.4}
hs.grid.ui.cellStrokeColor = {1, 1, 1, 1}
hs.grid.ui.cellStrokeWidth = 2
hs.grid.ui.highlightStrokeWidth = 20
hs.grid.ui.showExtraKeys = false

hs.grid.HINTS = {
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
    { "A", "S", "D", "F", "G", "H", "J", "K", "L", ";" },
    { "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" }
}


hs.window.animationDuration = 0 -- disable animations

winman_mode = "persistent" -- 可选值[persistent]: 持久模式, 留空即为非持久模式
winman_dynamicAdjustWindowLayout = false -- 窗口动态(聚焦后立即)调整布局全局总开关, 开启后, 可能性能下降

window_grids = {
    topHalf = "0,0 16x6",
    topThird = "0,0 16x4",
    topTwoThirds = "0,0 16x8",

    bottomHalf = "0,6 16x6",
    bottomThird = "0,8 16x4",
    bottomTwoThirds = "0,4 16x8",

    rightHalf = "8,0 8x12",
    rightThird = "11,0 6x12",
    rightTwoThirds = "5,0 11x12",

    leftHalf = "0,0 8x12",
    leftThird = "0,0 6x12",
    leftTwoThirds = "0,0 11x12",

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
    -- 缺点: 只能将已经启动的App窗口平铺
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
