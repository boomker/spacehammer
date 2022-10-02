-- 输入法切换

require 'modules.shortcut'

-- local INPUT_CHINESE = 'com.sogou.inputmethod.sogou.pinyin'
-- local INPUT_ABC = 'com.apple.keylayout.ABC'
-- local INPUT_HIRAGANA = 'com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese'

hs.fnutils.each(input_method_config.input_methods, function(item)
    hs.hotkey.bind(item.prefix, item.key, item.message, function()
        hs.keycodes.currentSourceID(item.inputmethodId)
    end)
end)

local function switchToABC(_, eventType, appObject)

    local curApplication = hs.application.frontmostApplication()
    local curAppBundleID = curApplication:bundleID()
    local curAppTitle = nil
    local curAppName = nil
    if curAppBundleID ~= nil then
        curAppName = hs.application.nameForBundleID(curAppBundleID)
    else
        curAppTitle = curApplication:title()
    end

    -- print(hs.inspect(curAppBundleID,curAppTitle, curAppName))

    if input_method_config.abc_apps ~= nil then
        for _, v in ipairs(input_method_config.abc_apps) do
            if v == curAppBundleID or v == curAppName or v == curAppTitle then
                hs.keycodes.currentSourceID(input_method_config.input_methods.abc.inputmethodId)
                -- hs.alert.show("🅰️- ON", 0.5)
                -- hs.alert.show(" 🔤️ - ON", 0.5)
                break
            end
        end
    end
end

local function switchToChinese(_, eventType, appObject)

    local curApplication = hs.application.frontmostApplication()
    local curAppBundleID = curApplication:bundleID()
    local curAppTitle = nil
    local curAppName = nil
    if curAppBundleID ~= nil then
        curAppName = hs.application.nameForBundleID(curAppBundleID)
    else
        curAppTitle = curApplication:title()
    end

    if input_method_config.chinese_apps ~= nil then
        for _, v in ipairs(input_method_config.chinese_apps) do
            if v == curAppBundleID or v == curAppName or v == curAppTitle then
                hs.keycodes.currentSourceID(input_method_config.input_methods.chinese.inputmethodId)
                -- hs.alert.show(" 🇨🇳️ - ON", 0.5)
                break
            end
        end
    end
end


local function appWatcher()
    hs.application.watcher.new(switchToABC):start()
    hs.application.watcher.new(switchToChinese):start()
    -- hs.spaces.watcher.new(focusedAppWindow):start()
end

local interval = 10

AppTimer = hs.timer.new(interval, appWatcher)
AppTimer:start()

-- 简体拼音
-- local function chinese()
--     hs.keycodes.currentSourceID(input_methods.INPUT_CHINESE)
-- end

-- -- ABC
-- local function abc()
--     hs.keycodes.currentSourceID(input_methods.INPUT_ABC)
-- end

-- 平假名
-- local function hiragana()
--     hs.keycodes.currentSourceID(INPUT_HIRAGANA)
-- end

-- if (input_methods ~= nil) then
--     hs.hotkey.bind(input_methods.abc.prefix, input_methods.abc.key, input_methods.abc.message, abc)
--     hs.hotkey.bind(input_methods.chinese.prefix, input_methods.chinese.key, input_methods.chinese.message, chinese)
--     -- hs.hotkey.bind(input_methods.japanese.prefix, input_methods.japanese.key, input_methods.japanese.message, hiragana)
-- end
