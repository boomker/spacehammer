-- 应用切换

-- require 'configs.shortcuts'
require 'configs.applicationConfig'

local app_info = {
    bundleId = nil,
    name = nil,
    initWindowLayout = nil,
    alwaysWindowLayout = nil,
    onPrimaryScreen = true,
}


-- 存储鼠标位置
local mousePositions = {}

local function setMouseToCenter(foucusedWindow)
    if foucusedWindow == nil then
        return
    end
    local frame = foucusedWindow:frame()
    local centerPosition = hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
    hs.mouse.absolutePosition(centerPosition)
end

local function setWindowLayout(appName, eventType, appObject)
    local appPID = appObject:pid()
    local appIdentifier = string.format("%s_%d", appObject:bundleID(), appPID)
    local setAppWindowToSpecScreen = function()
        local screens = hs.screen.allScreens()
        if app_info.onPrimaryScreen and #screens == 1 then
            return hs.screen.primaryScreen()
        else
            local primaryScreenID = hs.screen.primaryScreen():id()
            for _, screen in ipairs(screens) do
                if screen.id() ~= primaryScreenID then return screen end
            end
        end
    end

    if
        app_info.initWindowLayout and
        eventType == hs.application.watcher.activated and
        appObject:bundleID() == app_info.bundleId and
        not hs.settings.get(appIdentifier)
    then
        local layout = app_info.initWindowLayout
        local checkWindowFocused = function()
            local cwin = hs.window.focusedWindow()
            if cwin then
                local windowForAppObj = cwin:application()
                local windowForAppID = windowForAppObj:bundleID()
                -- return windowForAppID == appObject:bundleID()
                return windowForAppID == app_info.bundleId
            end
        end

        local execSetAppWindowGridLayout = function()
            local cwin = hs.window.focusedWindow()
            if cwin then
                hs.grid.set(cwin, layout, setAppWindowToSpecScreen())
                hs.settings.set(appIdentifier, true)
            end
        end

        hs.timer.waitUntil(checkWindowFocused, execSetAppWindowGridLayout)
        -- local windows = appObject:visibleWindows()
    end

    local checkInitWindowLayoutExist = function()
        if app_info.initWindowLayout then
            return hs.settings.get(appIdentifier)
        else
            return true
        end
    end

    if
        app_info.alwaysWindowLayout and
        eventType == hs.application.watcher.activated and
        appObject:bundleID() == app_info.bundleId and
        checkInitWindowLayoutExist()
    then
        local layout = app_info.alwaysWindowLayout
        -- local window = hs.window.focusedWindow()
        local windows = appObject:visibleWindows()
        for _, window in pairs(windows) do
            if window:isVisible() and window:isStandard() then
                hs.grid.set(window, layout, setAppWindowToSpecScreen())
            end
        end
    end
end

local function getAppID(appName)
    local osaScriptCodeStr =  string.format('id of app "%s"', appName)
    local ok, bundleID, _ = hs.osascript.applescript(osaScriptCodeStr)
    if ok then return bundleID end

    -- hs.application.enableSpotlightForNameSearches(true)
    local appObj = hs.application.get(appName)
    if appObj then return appObj:bundleID() end

    local Apps = {}
    local function SplitAndAddToTable(s, delimiter)
        for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
            if (match ~= "") then
                table.insert(Apps, match)
            end
        end
        -- return Apps
    end

    SplitAndAddToTable(hs.execute('find "/System/Applications"  -maxdepth 2 -name "*.app" '), "\n")
    SplitAndAddToTable(hs.execute('find "/Applications"  -maxdepth 2 -name "*.app" '), "\n")
    for _, app in ipairs(Apps) do
        local appLower = string.lower(app)
        local appLowerName = string.lower(appName)
        if string.match(app, appName) or string.match(appLower, appLowerName) then
            local appID = getAppID(app)
            if appID then return appID end
        end
    end

end

local function launchOrFocusApp(appInfo)

    local previousFocusedWindow = hs.window.focusedWindow()
    if previousFocusedWindow ~= nil then
        mousePositions[previousFocusedWindow:id()] = hs.mouse.absolutePosition()
    end

    local appBundleID = appInfo.bundleId
    local appName = appInfo.name
    if appBundleID then
        hs.application.launchOrFocusByBundleID(appBundleID)
    else
        -- hs.application.launchOrFocus(appName)
        appBundleID = getAppID(appName)
        if not appBundleID then return false end
        hs.application.launchOrFocusByBundleID(appBundleID)
        app_info.bundleId = appBundleID
    end

    -- 获取 application 对象
    local applications = hs.application.applicationsForBundleID(appBundleID)
    local application = nil
    for _, v in ipairs(applications) do application = v end

    local currentFocusedWindow = application:focusedWindow()
    if currentFocusedWindow and mousePositions[currentFocusedWindow:id()] then
        hs.mouse.absolutePosition(mousePositions[currentFocusedWindow:id()])
    else
        setMouseToCenter(currentFocusedWindow)
    end

    if appInfo.initWindowLayout or appInfo.alwaysWindowLayout then
        local appWindowLayoutWatcher = hs.application.watcher.new(setWindowLayout)
        appWindowLayoutWatcher:start()
    end
end

hs.fnutils.each(applications, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        if item.bundleId then
            app_info.bundleId = item.bundleId
            app_info.name = nil
        else
            app_info.name = item.name
            app_info.bundleId = nil
        end

        app_info.alwaysWindowLayout = nil
        app_info.initWindowLayout = nil
        if item.initWindowLayout then
            app_info.initWindowLayout = item.initWindowLayout
        else
            app_info.alwaysWindowLayout = item.alwaysWindowLayout
        end
        if item.initWindowLayout and item.alwaysWindowLayout then
            app_info.initWindowLayout = item.initWindowLayout
            app_info.alwaysWindowLayout = item.alwaysWindowLayout
        end

        if item.onPrimaryScreen then
            app_info.onPrimaryScreen = item.onPrimaryScreen
        end

        launchOrFocusApp(app_info)

    end)
end)
