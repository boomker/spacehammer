-- -- 展示本工程快捷键列表

require 'modules.base'
hs.loadSpoon("ModalMgr")
require 'modules.shortcut'

modifierKey2Symbol = {
    Ctrl = "⌃",
    Option = "⌥",
    Alt = "⌥",
    Shift = "⇧",
    Cmd = "⌘"
}

local focusedWindow = hs.window.focusedWindow()
if focusedWindow == nil then
    return
end
local screen = focusedWindow:screen():frame()

local COORIDNATE_X = screen.w / 2
local COORIDNATE_Y = screen.h / 2

-- 快捷键总数
local num = 0

-- 创建 Canvas
local canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })

-- TODO-JING 增加圆角
-- 背景面板
canvas:appendElements({
    id = 'pannel',
    action = 'fill',
    fillColor = { alpha = 0.9, red = 0, green = 0, blue = 0 },
    type = 'rectangle'
})

local function styleText(text)
    return hs.styledtext.new(text, {
        font = {
            name = "Monaco",
            size = 16
        },
        color = { hex = '#0096FA' },
        paragraphStyle = {
            lineSpacing = 5
        }
    })
end

local function formatText()

    -- 加载所有绑定的快捷键
    local Hotkeys = hs.hotkey.getHotkeys()
    local renderText = {}
    -- ==== 快捷键分类 ====

    -- 头部提示
    local tooltip = {}
    table.insert(tooltip, { msg = '[ToolTips]:' })
    table.insert(tooltip, { msg = 'Q: 退出当前面板' })
    table.insert(tooltip, { msg = 'Escape: 退出当前面板' })
    table.insert(tooltip, { msg = 'Hyper: Space键 = ⌃⌥⇧' })

    table.insert(tooltip, { msg = ' ' })

    -- 应用切换类
    local applicationSwitchText = {}
    table.insert(applicationSwitchText, { msg = '[Application Switch]:' })

    -- 窗口管理类
    local windowManagement = {}
    table.insert(windowManagement, { msg = '[Window Management]:' })

    -- 自定义按键映射类
    local customRemappings = {}
    table.insert(customRemappings, { msg = '[CustomRemapping]:' })

    -- 每行最多 40 个字符
    local MAX_LEN = 35
    -- 快捷键分类

    for i, v in ipairs(Hotkeys) do
        -- 以 ⌥ 开头，表示为应用切换快捷键
        if string.find(v.idx, '^⌃⌥') ~= nil then
            table.insert(applicationSwitchText, { msg = v.msg })
        end

        if i == #Hotkeys then
            table.insert(applicationSwitchText, { msg = "" })
        end
    end

    for i, v in ipairs(winman_keys) do
        if #v.prefix == 0 then
            v.prefix = "Hyper + W"
        elseif #v.prefix == 1 then
            v.prefix = "Hyper + W → " .. modifierKey2Symbol[v.prefix[1]]
        else
            v.prefix = "Hyper + W → " .. modifierKey2Symbol[v.prefix[1]] .. modifierKey2Symbol[v.prefix[2]]
        end
        table.insert(windowManagement, { msg = v.prefix .. " + " .. v.key .. ": " .. v.message })
        if i == #winman_keys then
            table.insert(windowManagement, { msg = "" })
        end
    end

    for _, v in ipairs(remapkeys) do
        -- if #v.prefix == 0 then
        --     v.prefix = "Hyper"
        -- elseif v.prefix == HyperKey then
        --     v.prefix = "Hyper"
        -- end

        table.insert(customRemappings, { msg = "Hyper" .. " + " .. v.key .. ": " .. v.message })
    end

    local regHotkeys = {}
    for _, v in ipairs(tooltip) do
        table.insert(regHotkeys, { msg = v.msg })
    end

    for _, v in ipairs(applicationSwitchText) do
        table.insert(regHotkeys, { msg = v.msg })
    end

    for _, v in ipairs(windowManagement) do
        table.insert(regHotkeys, { msg = v.msg })
    end

    for _, v in ipairs(customRemappings) do
        table.insert(regHotkeys, { msg = v.msg })
    end

    -- 文本定长
    for _, v in ipairs(regHotkeys) do
        num = num + 1
        local msg = v.msg
        local len = utf8len(msg)
        -- 超过最大长度，截断多余部分，截断的部分作为新的一行
        while len > MAX_LEN do
            local substr = utf8sub(msg, 1, MAX_LEN)
            table.insert(renderText, { line = substr })
            msg = utf8sub(msg, MAX_LEN + 1, len)
            len = utf8len(msg)
        end
        for i = 1, MAX_LEN - utf8len(msg), 1 do
            msg = msg .. ' '
        end
        table.insert(renderText, { line = msg })
    end
    return renderText
end

local function drawText(renderText)
    -- 每列最多 20 行
    local MAX_LINE_NUM = 33
    local w = 0
    local h = 0
    -- 文本距离分割线的距离
    local SEPRATOR_W = 9;

    -- 每一列需要显示的文本
    local column = ''
    for k, v in ipairs(renderText) do
        local line = v.line
        if math.fmod(k, MAX_LINE_NUM) == 0 then
            column = column .. line .. '  '
        else
            column = column .. line .. '  \n'
        end
        -- k mod MAX_LINE_NUM
        if math.fmod(k, MAX_LINE_NUM) == 0 then
            local itemText = styleText(column)
            local size = canvas:minimumTextSize(itemText)
            -- 多 text size w 累加
            w = w + size.w
            if k == MAX_LINE_NUM then
                h = size.h
            end
            canvas:appendElements({
                type = 'text',
                text = itemText,
                frame = { x = (k / MAX_LINE_NUM - 1) * size.w + SEPRATOR_W, y = 0, w = size.w + SEPRATOR_W, h = size.h }
            })
            canvas:appendElements({
                type = "segments",
                closed = false,
                -- strokeColor = { blue = 1 },
                strokeColor = { hex = '#0096FA' },
                action = "stroke",
                strokeWidth = 2,
                coordinates = { { x = (k / MAX_LINE_NUM) * size.w - SEPRATOR_W, y = 0 },
                    { x = (k / MAX_LINE_NUM) * size.w - SEPRATOR_W, y = h } },
            })
            column = ''
        end
    end
    if column ~= nil then
        local itemText = styleText(column)
        local size = canvas:minimumTextSize(itemText)
        w = w + size.w
        canvas:appendElements({
            type = 'text',
            text = itemText,
            -- frame = { x = math.ceil(num / MAX_LINE_NUM - 1) * size.w + SEPRATOR_W, y = 0, w = size.w + SEPRATOR_W,
            frame = {
                x = 2.0 * size.w + SEPRATOR_W,
                y = 0,
                w = size.w + SEPRATOR_W,
                h = size.h }
        })
        column = ''
    end

    -- 居中显示
    canvas:frame({ x = COORIDNATE_X - w / 2, y = COORIDNATE_Y - h / 2.2, w = w, h = h })
end

-- 默认不显示
local show = false

-- toggle show/hide
local function toggleHotkeysShow()
    if show then
        -- 0.3s 过渡
        canvas:hide(.3)
    else
        -- 0.3s 过渡
        canvas:show(.3)
    end
    show = not show
end

local function closeHotKeyShow()
    canvas:hide(.3)
    show = false
end

drawText(formatText())

-- ⌥/ 显示/隐藏快捷键列表
-- hs.hotkey.bind(hshelp_keys.prefix, hshelp_keys.key, toggleHotkeysShow)
-- Esc 关闭快捷键列表（仅在快捷键列表已显示情况下生效）
-- hs.hotkey.bind({}, 'escape', closeHotKeyShow)

-- 禁用快捷键alert消息
hs.hotkey.alertDuration = 0


if hshelp_keys then
    spoon.ModalMgr:new("ShowHSHelpKeys")
    local cmodal = spoon.ModalMgr.modal_list["ShowHSHelpKeys"]
    cmodal:bind('', 'escape', '退出', function()
        closeHotKeyShow()
        spoon.ModalMgr:deactivate({"ShowHSHelpKeys"})
    end)
    cmodal:bind('', 'Q', '退出 ', function()
        closeHotKeyShow()
        spoon.ModalMgr:deactivate({"ShowHSHelpKeys"})
    end)

    -- 绑定功 ShowHSHelpKeys快捷键
    hshelp_keys = hshelp_keys or {"alt", "C"}
    if string.len(hshelp_keys.key) > 0 then
        spoon.ModalMgr.supervisor:bind(hshelp_keys.prefix, hshelp_keys.key, "打开快捷键显示面板", function()
            toggleHotkeysShow()
            spoon.ModalMgr:activate({"ShowHSHelpKeys"})
        end)
    end
end
spoon.ModalMgr.supervisor:enter()