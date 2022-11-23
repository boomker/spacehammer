-- 应用切换

require("configs.applicationConfig")
require("modules.base")

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

---@diagnostic disable-next-line: unused-local
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
        app_info.initWindowLayout
        and eventType == hs.application.watcher.activated
        and appObject:bundleID() == app_info.bundleId
        and not hs.settings.get(appIdentifier)
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
        app_info.alwaysWindowLayout
        and eventType == hs.application.watcher.activated
        and appObject:bundleID() == app_info.bundleId
        and checkInitWindowLayoutExist()
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

local function getAppIdFromRunningApp(appNames)
    for _, v in ipairs(appNames) do
        local appTitle = v:gsub("^%l", string.upper) -- 首字母大写
        local appObj = hs.application.get(appTitle) or hs.application.get(v)
        if appObj then
            local bundleID = appObj:bundleID()
            local appBundleIDKey = v .. "_bundleId"
            hs.settings.set(appBundleIDKey, bundleID)
            -- print(hs.inspect(v .. " | " .. bundleID))
            return bundleID
        end
    end
    return false
end

local function getAppID(appName)
    local appBundleID = hs.settings.get(appName .. "_bundleId")
    if appBundleID then
        return appBundleID
    end

        --[[
            "kMDItemDisplayName = '*iterm*'c                                    -- "c": 大小写不敏感
                && (kMDItemKind = 'Application' || kMDItemKind = '应用程序')    -- "指定文件后缀为 `.app`"
                && kMDItemContentType = 'com.apple.application-bundle'"         -- "指定仅App 应用程序"
        ]]
    local cmdOpts = string.format(
        "(kMDItemDisplayName = '*%s*'c  || kMDItemCFBundleIdentifier = '*%s*'c) \
        && (kMDItemKind = 'Application' || kMDItemKind = '应用程序') \
        && kMDItemContentType = 'com.apple.application-bundle'",
        appName,
        appName
    )
    local cmdStr = "mdfind " .. '"' .. cmdOpts .. '"'
    local results, status, _, rc = hs.execute(cmdStr)
    local result = split(results, "\n")[1]
    if result and status and rc == 0 then
        local osaScriptCodeStr = string.format('id of app "%s"', trim(result))
        local ok, bundleID, _ = hs.osascript.applescript(osaScriptCodeStr)
        if ok then
            local appBundleIDKey = appName .. "_bundleId"
            hs.settings.set(appBundleIDKey, bundleID)
            return bundleID
        end
    end
    -- end
end

local function launchOrFocusApp(appInfo)
    local previousFocusedWindow = hs.window.focusedWindow()
    if previousFocusedWindow ~= nil then
        mousePositions[previousFocusedWindow:id()] = hs.mouse.absolutePosition()
    end

    local appBundleID = appInfo.bundleId
    local appName_items = appInfo.name
    if appBundleID then
        hs.application.launchOrFocusByBundleID(appBundleID)
    else
        -- hs.application.launchOrFocus(appName)
        if type(appName_items) == "table" then
            -- print(hs.inspect(appName_items))
            appBundleID = getAppIdFromRunningApp(appName_items)
            if not appBundleID then
                for _, v in ipairs(appName_items) do
                    appBundleID = getAppID(v)
                    if appBundleID then break end
                end
            end
        else
            appBundleID = getAppID(appName_items)
        end
        if not appBundleID then return false end
        hs.application.launchOrFocusByBundleID(appBundleID)
        app_info.bundleId = appBundleID
    end

    -- 获取 application 对象
    local applications = hs.application.applicationsForBundleID(appBundleID)
    local application = nil
    for _, v in ipairs(applications) do
        application = v
    end

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
