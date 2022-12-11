---@diagnostic disable: lowercase-global
-- 窗口管理

-- 关闭动画持续时间
hs.window.animationDuration = 0

local lastSeenChain = nil
local lastSeenWindow = nil
local lastSeenAt = 0

LAYOUT_COUNT = {
    grid = 0,
    hflatten = 0,
    vflatten = 0,
}

alwaysAdjustAppWindowLayoutData = {
    appNames = {},
}

-- 窗口枚举
AUTO_LAYOUT_TYPE = {
    -- 网格式布局
    GRID = "GRID",
    -- 水平或垂直评分
    HORIZONTAL_OR_VERTICAL = "HORIZONTAL_OR_VERTICAL",
    HORIZONTAL_OR_VERTICAL_R = "ROTATE",
}

function same_application(auto_layout_type)
    local focusedWindow = hs.window.focusedWindow()
    local application = focusedWindow:application()
    -- 当前屏幕
    local focusedScreen = focusedWindow:screen()
    -- 同一应用的所有窗口
    local visibleWindows = application:visibleWindows()
    for k, visibleWindow in ipairs(visibleWindows) do
        -- 关于 Standard window 可参考：http://www.hammerspoon.org/docs/hs.window.html#isStandard
        -- 例如打开 Finder 就一定会存在一个非标准窗口，这种窗口需要排除
        if not visibleWindow:isStandard() then
            table.remove(visibleWindows, k)
        end
        if visibleWindow ~= focusedWindow then
            -- 将同一应用的其他窗口移动到当前屏幕
            visibleWindow:moveToScreen(focusedScreen)
        end
    end
    layout_auto(visibleWindows, auto_layout_type)
end

function same_space(auto_layout_type)
    local window_filter = hs.window.filter.new():setOverrideFilter({
        visible = true,
        fullscreen = false,
        hasTitlebar = true,
        currentSpace = true,
        allowRoles = "AXStandardWindow",
    })

    local all_windows = window_filter:getWindows()

    local windows = {}
    for _, window in ipairs(all_windows) do
        if window ~= nil and window:isStandard() and not window:isMinimized() then
            table.insert(windows, window)
        end
    end
    layout_auto(windows, auto_layout_type)
end

function smart_rotate_layout(windows)
    local focusedScreen = hs.screen.mainScreen()
    local focusedScreenFrame = focusedScreen:frame()
    -- 如果是竖屏，就水平均分，否则垂直均分
    if isWhatLayout() == "horizontal" then
        LAYOUT_COUNT.hflatten = LAYOUT_COUNT.hflatten + 1
        layout_horizontal(windows, focusedScreenFrame)
    elseif isWhatLayout() == "vertical" then
        LAYOUT_COUNT.vflatten = LAYOUT_COUNT.vflatten + 1
        layout_vertical(windows, focusedScreenFrame)
    else
        LAYOUT_COUNT.grid = LAYOUT_COUNT.grid + 1
        layout_grid(windows)
    end
end

function layout_auto(windows, auto_layout_type)
    if AUTO_LAYOUT_TYPE.GRID == auto_layout_type then
        layout_grid(windows)
    elseif AUTO_LAYOUT_TYPE.HORIZONTAL_OR_VERTICAL == auto_layout_type then
        layout_horizontal_or_vertical(windows)
    else
        smart_rotate_layout(windows)
    end
end

-- 平铺模式-网格均分
function layout_grid(windows)
    LAYOUT_COUNT.grid = LAYOUT_COUNT.grid + 1
    local focusedScreen = hs.screen.mainScreen()
    -- TODO-JING num = 3、5、7、8、10、11、13、14、15
    -- TODO-JING せめて num = 3 の問題を消して

    local layout = {
        {
            num = 1,
            row = 0,
            column = 0,
        },
        {
            num = 2,
            row = 0,
            column = 1,
        },
        {
            num = 4,
            row = 1,
            column = 1,
        },
        {
            num = 6,
            row = 1,
            column = 2,
        },
        {
            num = 9,
            row = 2,
            column = 2,
        },
        {
            num = 12,
            row = 2,
            column = 3,
        },
        {
            num = 16,
            row = 3,
            column = 3,
        },
    }

    local windowNum = #windows
    local focusedScreenFrame = focusedScreen:frame()
    for _, item in ipairs(layout) do
        if windowNum <= item.num then
            local column = item.column
            local row = item.row
            if isVerticalScreen(focusedScreen) then
                if item.column > item.row then
                    column = item.row
                    row = item.column
                end
            end
            local widthForPerWindow = focusedScreenFrame.w / (column + 1)
            local heightForPerWindow = focusedScreenFrame.h / (row + 1)
            local nth = 1

            for i = 0, column, 1 do
                for j = 0, row, 1 do
                    -- 已没有可用窗口
                    if nth > windowNum then
                        break
                    end
                    local window = windows[nth]
                    local windowFrame = window:frame()
                    windowFrame.x = focusedScreenFrame.x + i * widthForPerWindow
                    windowFrame.y = focusedScreenFrame.y + j * heightForPerWindow
                    windowFrame.w = widthForPerWindow - 2
                    windowFrame.h = heightForPerWindow - 2
                    window:setFrame(windowFrame)
                    -- 让窗口获取焦点以将窗口置前
                    window:focus()
                    nth = nth + 1
                end
            end
            break
        end
    end
end

-- 平铺模式 - 水平（竖屏）或垂直（横屏）均分
function layout_horizontal_or_vertical(windows)
    local focusedScreen = hs.screen.mainScreen()
    local focusedScreenFrame = focusedScreen:frame()
    -- 如果是竖屏，就水平均分，否则垂直均分
    if isVerticalScreen(focusedScreen) then
        LAYOUT_COUNT.hflatten = LAYOUT_COUNT.hflatten + 1
        layout_horizontal(windows, focusedScreenFrame)
    else
        LAYOUT_COUNT.vflatten = LAYOUT_COUNT.vflatten + 1
        layout_vertical(windows, focusedScreenFrame)
    end
end

-- 平铺模式 - 水平均分
function layout_horizontal(windows, focusedScreenFrame)
    local windowNum = #windows
    local heightForPerWindow = focusedScreenFrame.h / windowNum
    for i, window in ipairs(windows) do
        local windowFrame = window:frame()
        windowFrame.x = focusedScreenFrame.x
        windowFrame.y = focusedScreenFrame.y + heightForPerWindow * (i - 1)
        windowFrame.w = focusedScreenFrame.w
        windowFrame.h = heightForPerWindow - 2
        window:setFrame(windowFrame)
        window:focus()
    end
end

-- 平铺模式 - 垂直均分
function layout_vertical(windows, focusedScreenFrame)
    local windowNum = #windows
    local widthForPerWindow = focusedScreenFrame.w / windowNum
    for i, window in ipairs(windows) do
        local windowFrame = window:frame()
        windowFrame.x = focusedScreenFrame.x + widthForPerWindow * (i - 1)
        windowFrame.y = focusedScreenFrame.y
        windowFrame.w = widthForPerWindow - 2
        windowFrame.h = focusedScreenFrame.h
        window:setFrame(windowFrame)
        window:focus()
    end
end

-- 判断指定屏幕是否为竖屏
function isVerticalScreen(screen)
    if screen:rotate() == 90 or screen:rotate() == 270 then
        return true
    else
        return false
    end
end

function isWhatLayout()
    local gCount = LAYOUT_COUNT.grid
    local hCount = LAYOUT_COUNT.hflatten
    local vCount = LAYOUT_COUNT.vflatten
    local minVal = math.min(gCount, hCount, vCount)
    if gCount == minVal then
        return "grid"
    elseif hCount == minVal then
        return "horizontal"
    else
        return "vertical"
    end
end

function kill_same_application()
    local focusedWindow = hs.window.focusedWindow()
    local application = focusedWindow:application()
    -- 当前屏幕
    -- local focusedScreen = focusedWindow:screen()
    -- 同一应用的所有窗口
    application:kill()
end

function close_same_application_other_windows()
    local focusedWindow = hs.window.focusedWindow()
    local application = focusedWindow:application()
    local visibleWindows = application:visibleWindows()
    for k, visibleWindow in ipairs(visibleWindows) do
        if not visibleWindow:isStandard() then
            table.remove(visibleWindows, k)
        end
        if visibleWindow ~= focusedWindow then
            visibleWindow:close()
        end
    end
end

----------------------------------------------------------------

-- Grid 轮切模式实现
sequenceNumber = 1
function rotateWinGrid(movements)
    local chainResetInterval = 2 -- seconds
    local cycleLength = #movements
    -- local sequenceNumber = 1

    -- return function()
    local execSetGrid = function()
        local win = hs.window.frontmostWindow()
        local id = win:id()
        local now = hs.timer.secondsSinceEpoch()
        local screen = win:screen()

        if lastSeenChain ~= movements or lastSeenAt < now - chainResetInterval or lastSeenWindow ~= id then
            sequenceNumber = 1
            lastSeenChain = movements
            -- elseif (sequenceNumber == 1) then
            -- At end of chain, restart chain on next screen.
            -- screen = screen:next()
        end

        lastSeenAt = now
        lastSeenWindow = id

        hs.grid.set(win, movements[sequenceNumber], screen)
        sequenceNumber = sequenceNumber % cycleLength + 1
    end
    return execSetGrid()
end

----------------------------------------------------------------
-- 全局任意方式切换后自动调整布局的实现
function AppWindowAutoLayout()
    hs.fnutils.each(applications, function(item)
        hs.alert.show("!!!start: 即将自动调整窗口布局", 0.5)

        if item.anytimeAdjustWindowLayout and item.alwaysWindowLayout then
            local Appname = nil
            if item.bundleId then
                Appname = hs.application.nameForBundleID(item.bundleId)
            else
                Appname = item.name
            end
            local appMaplayout = { [Appname] = item.alwaysWindowLayout }
            table.insert(alwaysAdjustAppWindowLayoutData.appNames, Appname)
            table.insert(alwaysAdjustAppWindowLayoutData, appMaplayout)
        end

        if #alwaysAdjustAppWindowLayoutData ~= 0 then
            local awf = hs.window.filter.new(alwaysAdjustAppWindowLayoutData.appNames)
            awf:subscribe(hs.window.filter.windowFocused, function(window, appName)
                hs.alert.show("即将自动调整窗口布局", 0.5)
                local layout = nil
                for _, v in ipairs(alwaysAdjustAppWindowLayoutData) do
                    if v[appName] then
                        layout = v[appName]
                    end
                end

                hs.grid.set(window, layout)
            end)
        end
    end)
end
