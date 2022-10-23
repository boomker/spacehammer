-- 输入法切换

require 'configs.shortcuts'
-- require 'modules.status-message'

local message = require('modules.status-message')
local messageABC = message.new(' 🔤️  - ON')
local messageSogou = message.new(' 🇨🇳️ - ON')

hs.fnutils.each(input_method_config.input_methods, function(item)
    if type(item) ~= 'string' then
        hs.hotkey.bind(item.prefix, item.key, item.message, function()
            if string.match(item.inputmethodId, 'abc') then
                messageABC:notify()
            else
                messageSogou:notify()
            end
            hs.keycodes.currentSourceID(item.inputmethodId)
        end)
    end
end)

local function switchToTgtInputMethod(appTitle, appObject)

    local curAppName = nil
    local curAppObj = nil
    local curAppBundleID = nil
    local curAppTitle = appTitle
    if appTitle and not appObject then
        -- curAppObj = hs.appfinder.appFromName(curAppTitle)
        curAppObj =hs.application.get(curAppTitle)
        curAppBundleID = curAppObj:bundleID()
    else
        curAppBundleID = appObject:bundleID()
    end

    if curAppBundleID then
        curAppName = hs.application.nameForBundleID(curAppBundleID)
        -- curAppName = appObject:name()
    end
    local abc_apps = input_method_config.abc_apps
    local chinese_apps = input_method_config.chinese_apps

    local curAppIdentifiers = {curAppName, curAppBundleID, curAppTitle}
    local isExistABC = hs.fnutils.some(curAppIdentifiers, function(identifier)
        return hs.fnutils.contains(abc_apps, identifier)
    end)

    if isExistABC then
        hs.keycodes.currentSourceID(input_method_config.input_methods.abc.inputmethodId)
        messageABC:notify()
    else
        local isExistChinese = hs.fnutils.some(curAppIdentifiers, function(identifier)
            return hs.fnutils.contains(chinese_apps, identifier)
        end)
        if isExistChinese then
            hs.keycodes.currentSourceID(input_method_config.input_methods.chinese.inputmethodId)
            messageSogou:notify()
        end
    end
end

local function appWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        switchToTgtInputMethod(appName, appObject)
    end
end

local inputmethodWatcher = function() hs.application.watcher.new(appWatcher):start() end

-- inputmethodWatcher()
local interval = 2

AppTimer = hs.timer.new(interval, inputmethodWatcher)
AppTimer:start()
