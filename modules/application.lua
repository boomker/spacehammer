-- 应用切换

require 'modules.shortcut'

local app_info = {
    app_bundle_id = nil,
    app_name = nil,
    initWindowLayout = nil,
    alwaysWindowLayout = nil,
    onPrimaryScreen = true
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
                if screen.id() ~= primaryScreenID then
                    return screen
                end
            end
        end
    end

    if
        app_info.initWindowLayout and
        eventType == hs.application.watcher.activated and
        appObject:bundleID() == app_info.app_bundle_id and
        not hs.settings.get(appIdentifier)
    then
        local layout = app_info.initWindowLayout
        print('------get initlayout-----')
        local checkWindowFocused = function()
            local cwin = hs.window.focusedWindow()
            if cwin then
                local windowForApp = cwin:application()
                local windowForAppID = windowForApp:bundleID()
                return windowForAppID == appObject:bundleID()
            end
        end

        local execSetAppWindowGrid = function()
            local cwin = hs.window.focusedWindow()
            hs.grid.set(cwin, layout, setAppWindowToSpecScreen())
            hs.settings.set(appIdentifier, true)
            print('===end: initWindowlayout seted')
        end

        hs.timer.waitUntil(checkWindowFocused, execSetAppWindowGrid)
        -- local windows = appObject:visibleWindows()
    end

    if
        app_info.alwaysWindowLayout and
        eventType == hs.application.watcher.activated and
        appObject:bundleID() == app_info.app_bundle_id and
        hs.settings.get(appIdentifier)
    then
        local layout = app_info.alwaysWindowLayout
        local window = hs.window.focusedWindow()
        hs.grid.set(window, layout, setAppWindowToSpecScreen())
        -- local windows = appObject:visibleWindows()
        -- for _, window in pairs(windows) do
        --     hs.grid.set(window, layout)
        -- end
    end
end

local function launchOrFocusApp(appInfo)

    local previousFocusedWindow = hs.window.focusedWindow()
    if previousFocusedWindow ~= nil then
        mousePositions[previousFocusedWindow:id()] = hs.mouse.absolutePosition()
    end

    local appBundleID = appInfo.app_bundle_id
    local appName = appInfo.app_name
    if appBundleID ~= nil then
        hs.application.launchOrFocusByBundleID(appBundleID)
    else
        -- hs.application.launchOrFocus(appName)
        local osaScriptCodeStr =  string.format('id of app "%s"', appName)
        local ok, bundleID , _ = hs.osascript.applescript(osaScriptCodeStr)
        if ok then
            appBundleID = bundleID
            hs.application.launchOrFocusByBundleID(bundleID)
            appInfo.app_bundle_id = bundleID
        end
    end

    -- 获取 application 对象
    local applications = hs.application.applicationsForBundleID(appBundleID)
    local application = nil
    for _, v in ipairs(applications) do application = v end

    local currentFocusedWindow = application:focusedWindow()
    if currentFocusedWindow ~= nil and mousePositions[currentFocusedWindow:id()] ~= nil then
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
            app_info.app_bundle_id = item.bundleId
            app_info.app_name = nil
        else
            app_info.app_name = item.name
            app_info.app_bundle_id = nil
        end

        app_info.alwaysWindowLayout = nil
        app_info.initWindowLayout = nil
        if item.initWindowLayout then
            app_info.initWindowLayout = item.initWindowLayout
            -- app_info.alwaysWindowLayout = nil
        else
            app_info.alwaysWindowLayout = item.alwaysWindowLayout
            -- app_info.initWindowLayout = nil
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
