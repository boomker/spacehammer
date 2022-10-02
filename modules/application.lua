-- 应用切换

require 'modules.shortcut'

local app_info = {
    app_bundle_id = nil,
    app_name = nil
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

local function launchOrFocusApp(app_info)

    local previousFocusedWindow = hs.window.focusedWindow()
    if previousFocusedWindow ~= nil then
        mousePositions[previousFocusedWindow:id()] = hs.mouse.absolutePosition()
    end

    local appBundleID = app_info.app_bundle_id
    local appName = app_info.app_name
    if appBundleID ~= nil then
        hs.application.launchOrFocusByBundleID(appBundleID)
    else
        -- hs.application.launchOrFocus(appName)
        local osaScriptCodeStr =  string.format('id of app "%s"', appName)
        local ok, bundleID, _ = hs.osascript.applescript(osaScriptCodeStr)
        if ok then
            appBundleID = bundleID
            hs.application.launchOrFocusByBundleID(appBundleID)
        end
    end

    -- 获取 application 对象
    local applications = hs.application.applicationsForBundleID(appBundleID)
    local application = nil
    for _, v in ipairs(applications) do
        application = v
    end

    local currentFocusedWindow = application:focusedWindow()
    if currentFocusedWindow ~= nil and mousePositions[currentFocusedWindow:id()] ~= nil then
        hs.mouse.absolutePosition(mousePositions[currentFocusedWindow:id()])
    else
        setMouseToCenter(currentFocusedWindow)
    end
end

hs.fnutils.each(applications, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        if item.bundleId then
            app_info.app_bundle_id = item.bundleId
        else
            app_info.app_name = item.name
        end
        launchOrFocusApp(app_info)
    end)
end)
