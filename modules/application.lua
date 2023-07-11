-- 应用切换

require("configs.applicationConfig")
require("modules.base")
hs.application.enableSpotlightForNameSearches(true)

local AppObjInfo = {
    bundleId = nil,
    name = nil,
    initWindowLayout = nil,
    alwaysWindowLayout = nil,
    onPrimaryScreen = false,
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
        if AppObjInfo.onPrimaryScreen or (#screens == 1) then
            return hs.screen.primaryScreen()
        end
        if AppObjInfo.onBackupScreen and (#screens ~= 1) then
            local primaryScreenID = hs.screen.primaryScreen():id()
            for _, screen in ipairs(screens) do
                -- print("psid: ", primaryScreenID, "sid: ", screen:id())
                if screen:id() ~= primaryScreenID then
                    return screen
                end
            end
        end
    end

    if
        AppObjInfo.initWindowLayout
        and eventType == hs.application.watcher.activated
        and appObject:bundleID() == AppObjInfo.bundleId
        and not hs.settings.get(appIdentifier)
    then
        local layout = AppObjInfo.initWindowLayout
        local checkWindowFocused = function()
            local cwin = hs.window.focusedWindow()
            if cwin then
                local windowForAppObj = cwin:application()
                local windowForAppID = windowForAppObj:bundleID()
                -- return windowForAppID == appObject:bundleID()
                return windowForAppID == AppObjInfo.bundleId
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
    end

    local checkInitWindowLayoutSeted = function()
        if AppObjInfo.initWindowLayout then
            return hs.settings.get(appIdentifier)
        else
            return true
        end
    end

    if
        AppObjInfo.alwaysWindowLayout
        and eventType == hs.application.watcher.activated
        and appObject:bundleID() == AppObjInfo.bundleId
        and checkInitWindowLayoutSeted()
    then
        local layout = AppObjInfo.alwaysWindowLayout
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
        -- local appObj = hs.application.get(appTitle) or hs.application.get(v)
        local appObj = hs.application.find(appTitle, true) or hs.application.find(v, true)
        if appObj and string.len(appObj:title()) == string.len(appTitle) then
            local bundleID = appObj:bundleID()
            local appBundleIDKey = v .. "_bundleId"
            hs.settings.set(appBundleIDKey, bundleID)
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
end

local function launchOrFocusApp(appInfo)
    local previousFocusedWindow = hs.window.focusedWindow()
    if previousFocusedWindow ~= nil then
        mousePositions[previousFocusedWindow:id()] = hs.mouse.absolutePosition()
    end

    local appBundleID = appInfo.bundleId
    local appNameItems = appInfo.name
    if appBundleID then
        hs.application.launchOrFocusByBundleID(appBundleID)
        -- print(hs.inspect(x))
    else
        appBundleID = getAppIdFromRunningApp(appNameItems)
        if appBundleID then
            -- AppLaunchState = hs.application.launchOrFocusByBundleID(appBundleID)
            local appDetails = hs.application.infoForBundleID(appBundleID)
            WhetherIsAgent = appDetails.LSUIElement
        end
        if WhetherIsAgent or not appBundleID then
            for _, v in ipairs(appNameItems) do
                appBundleID = getAppID(v)
                if appBundleID then break end
            end
            if not appBundleID then
                return false
            end
        end
        hs.application.launchOrFocusByBundleID(appBundleID)
        appInfo.bundleId = appBundleID
    end

    -- 获取 application 对象
    local applications = hs.application.applicationsForBundleID(appBundleID)
    if applications[1] then
        local currentFocusedWindow = applications[1]:focusedWindow()
        -- print(hs.inspect(applications), currentFocusedWindow)
        if currentFocusedWindow and mousePositions[currentFocusedWindow:id()] then
            hs.mouse.absolutePosition(mousePositions[currentFocusedWindow:id()])
        else
            setMouseToCenter(currentFocusedWindow)
        end
    end

    if appInfo.initWindowLayout or appInfo.alwaysWindowLayout then
        local appWindowLayoutWatcher = hs.application.watcher.new(setWindowLayout)
        appWindowLayoutWatcher:start()
    end
end

hs.fnutils.each(applications, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        if item.bundleId then
            AppObjInfo.bundleId = item.bundleId
            AppObjInfo.name = nil
        else
            AppObjInfo.name = item.name
            AppObjInfo.bundleId = nil
        end

        AppObjInfo.alwaysWindowLayout = nil
        AppObjInfo.initWindowLayout = nil
        if item.initWindowLayout then
            AppObjInfo.initWindowLayout = item.initWindowLayout
        else
            AppObjInfo.alwaysWindowLayout = item.alwaysWindowLayout
        end
        if item.initWindowLayout and item.alwaysWindowLayout then
            AppObjInfo.initWindowLayout = item.initWindowLayout
            AppObjInfo.alwaysWindowLayout = item.alwaysWindowLayout
        end

        if item.onPrimaryScreen then
            AppObjInfo.onPrimaryScreen = item.onPrimaryScreen
        else
            AppObjInfo.onPrimaryScreen = false
        end

        launchOrFocusApp(AppObjInfo)
    end)
end)
