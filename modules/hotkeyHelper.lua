---@diagnostic disable: lowercase-global
-- 展示本工程快捷键列表

hs.loadSpoon("ModalMgr")
require("modules.base")
require("configs.winmanShortcuts")
require("configs.remapingShortcuts")

-- 禁用快捷键alert消息
hs.hotkey.alertDuration = 0

local keyName2Symbol = {
    Ctrl = "⌃",
    Option = "⌥",
    Alt = "⌥",
    Shift = "⇧",
    Cmd = "⌘",
    left = "⬅︎",
    right = "➡",
    up = "⬆︎",
    down = "⬇︎",
}

local curScreen = hs.screen.mainScreen()
local screenFrame = curScreen:frame()
local COORIDNATE_X = screenFrame.w / 2
local COORIDNATE_Y = screenFrame.h / 2

-- 快捷键总数
local num = 0

-- 创建 Canvas
canvass = {}
local renderText = {
    appHotKeys = {},
    windowMHotKeys = {},
}

local canvas1 = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
local canvas2 = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })

-- 背景面板
canvas1:appendElements({
    id = "pannel",
    action = "fill",
    type = "rectangle",
    fillColor = { alpha = 0.9, red = 0, green = 0, blue = 0 },
    roundedRectRadii = { xRadius = 6.0, yRadius = 6.0 },
})
canvas2:appendElements({
    id = "pannel",
    action = "fill",
    type = "rectangle",
    fillColor = { alpha = 0.9, red = 0, green = 0, blue = 0 },
    roundedRectRadii = { xRadius = 6.0, yRadius = 6.0 },
})
canvass[1] = canvas1
canvass[2] = canvas2

local function styleText(text)
    return hs.styledtext.new(text, {
        font = {
            name = "Menlo",
            size = 16,
        },
        color = { hex = "#0096FA" },
        paragraphStyle = {
            lineSpacing = 5,
        },
    })
end

local function drawText(tag, renderTextData, ccanvas)
    -- 每列最多 22 行
    if tag == "all" then
        MAX_LINE_NUM = 21
        xl = 1
    else
        MAX_LINE_NUM = 29
        xl = 1
        -- xl = 1.97
    end

    local w = 0
    local h = 0
    -- 文本距离分割线的距离
    local SEPRATOR_W = 3

    -- 每一列需要显示的文本
    local column = ""
    for k, v in ipairs(renderTextData) do
        local line = v.line
        if math.fmod(k, MAX_LINE_NUM) == 0 then
            column = column .. line .. "  "
        else
            column = column .. line .. "  \n"
        end
        -- k mod MAX_LINE_NUM
        if math.fmod(k, MAX_LINE_NUM) == 0 then
            local itemText = styleText(column)
            local size = ccanvas:minimumTextSize(itemText)
            -- 多 text size w 累加
            w = w + size.w
            if k == MAX_LINE_NUM then
                h = size.h
            end
            ccanvas:appendElements({
                type = "text",
                text = itemText,
                frame = { x = (k / MAX_LINE_NUM - 1) * size.w + SEPRATOR_W, y = 0, w = size.w + SEPRATOR_W, h = size.h },
            })
            ccanvas:appendElements({
                type = "segments",
                closed = false,
                strokeColor = { hex = "#0096FA" },
                action = "stroke",
                strokeWidth = 2,
                coordinates = {
                    { x = (k / MAX_LINE_NUM) * size.w - SEPRATOR_W, y = 0 },
                    { x = (k / MAX_LINE_NUM) * size.w - SEPRATOR_W, y = h },
                },
            })
            column = ""
        end
    end

    if column ~= nil then
        local itemText = styleText(column)
        local size = ccanvas:minimumTextSize(itemText)
        w = w + size.w
        ccanvas:appendElements({
            type = "text",
            text = itemText,
            frame = {
                -- x = math.ceil(num / MAX_LINE_NUM - 1) * size.w + SEPRATOR_W,
                -- y = 0,
                -- w = size.w + SEPRATOR_W,
                -- h = size.h

                x = xl * size.w + SEPRATOR_W,
                y = 0,
                w = size.w + SEPRATOR_W,
                h = size.h,
            },
        })
        column = ""
    end

    -- 居中显示
    ccanvas:frame({ x = COORIDNATE_X - w / 2, y = COORIDNATE_Y - h / 2, w = w, h = h })
end

local function formatText(tag)
    -- ==== 快捷键分类 ====
    -- 头部提示
    local tooltip = {}
    table.insert(tooltip, { msg = "[ToolTips]:" })
    table.insert(tooltip, { msg = "Q: 退出当前面板" })
    table.insert(tooltip, { msg = "Escape: 退出当前面板" })
    table.insert(tooltip, { msg = "Hyper: Space键 = ⌃⌥⇧" })

    table.insert(tooltip, { msg = " " })
    local applicationSwitchText = {}
    local windowManagement = {}

    -- 每行最多 38 个字符
    local MAX_LEN = 38
    if tag == "WindowMOnly" then
        -- 窗口管理类
        table.insert(windowManagement, { msg = "[Window Management]:" })

        for _, v in ipairs(winman_keys) do
            if v.tag == "origin" or v.tag == "tile" then
                if #v.prefix == 0 then
                    v.prefix = "⌃⌥⇧ + W + "
                elseif #v.prefix == 1 then
                    v.prefix = "⌃⌥⇧ + W + " .. keyName2Symbol[v.prefix[1]]
                else
                    v.prefix = "⌃⌥⇧ + W + " .. keyName2Symbol[v.prefix[1]] .. keyName2Symbol[v.prefix[2]]
                end
            elseif v.tag == "grid" then
                if #v.prefix == 0 then
                    v.prefix = "⌃⌥⇧ + G + "
                end
            else
                print(hs.inspect(v))
            end

            table.insert(windowManagement, { msg = v.prefix .. (keyName2Symbol[v.key] or v.key) .. " : " .. v.message })
        end
    else
        -- 加载所有绑定的快捷键
        local Hotkeys = hs.hotkey.getHotkeys()
        -- 应用切换类
        table.insert(applicationSwitchText, { msg = "[应用切换和自定按键映射]:" })

        for i, v in ipairs(Hotkeys) do
            -- 以 ⌥ 开头，表示为应用切换快捷键
            if string.find(v.idx, "^⌃⌥") ~= nil then
                table.insert(applicationSwitchText, { msg = v.msg })
            end

            if i == #Hotkeys then
                table.insert(applicationSwitchText, { msg = "" })
            end
        end
    end

    local regHotkeys = {}
    for _, v in ipairs(tooltip) do
        table.insert(regHotkeys, { msg = v.msg })
    end

    if #applicationSwitchText > 1 then
        for _, v in ipairs(applicationSwitchText) do
            table.insert(regHotkeys, { msg = v.msg })
        end
    end

    if #windowManagement > 1 then
        for _, v in ipairs(windowManagement) do
            table.insert(regHotkeys, { msg = v.msg })
        end
    end

    -- 文本定长
    for _, v in ipairs(regHotkeys) do
        num = num + 1
        local msg = v.msg
        local len = utf8len(msg)
        -- 超过最大长度，截断多余部分，截断的部分作为新的一行
        while len > MAX_LEN do
            local substr = utf8sub(msg, 1, MAX_LEN)
            if tag == "all" then
                table.insert(renderText.appHotKeys, { line = substr })
            else
                table.insert(renderText.windowMHotKeys, { line = substr })
            end
            msg = utf8sub(msg, MAX_LEN + 1, len)
            len = utf8len(msg)
        end
        for _ = 1, MAX_LEN - utf8len(msg), 1 do
            msg = msg .. " "
        end
        if tag == "all" then
            table.insert(renderText.appHotKeys, { line = msg })
        else
            table.insert(renderText.windowMHotKeys, { line = msg })
        end
    end
    return renderText
end

-- toggle show/hide
local function toggleHotkeysShow(ccanvas)
    if ccanvas:isShowing() and ccanvas:isVisible() then
        -- 0.3s 过渡
        ccanvas:hide(0.3)
    else
        -- 0.3s 过渡
        ccanvas:show(0.3)
    end
end

local function closeHotKeyShow()
    canvass[1]:hide(0.3)
    canvass[2]:hide(0.3)
end

function showHSHotKeysPane(tag)
    if tag == "all" and #renderText.appHotKeys == 0 then
        formatText("all")
        drawText("all", renderText.appHotKeys, canvass[1])
        ccanvas = canvass[1]
    elseif tag == "WindowMOnly" and #renderText.windowMHotKeys == 0 then
        formatText("WindowMOnly")
        drawText("WindowMOnly", renderText.windowMHotKeys, canvass[2])
        ccanvas = canvass[2]
    else
        if tag == "all" then
            drawText("all", renderText.appHotKeys, canvass[1])
            ccanvas = canvass[1]
        else
            drawText("WindowMOnly", renderText.windowMHotKeys, canvass[2])
            ccanvas = canvass[2]
        end
    end
    toggleHotkeysShow(ccanvas)

    spoon.ModalMgr:new("ShowHSHelpKeys")
    local cmodal = spoon.ModalMgr.modal_list["ShowHSHelpKeys"]
    cmodal:bind("", "escape", "退出", function()
        closeHotKeyShow()
        spoon.ModalMgr:deactivate({ "ShowHSHelpKeys" })
    end)
    cmodal:bind("", "Q", "退出 ", function()
        closeHotKeyShow()
        spoon.ModalMgr:deactivate({ "ShowHSHelpKeys" })
    end)

    spoon.ModalMgr:deactivateAll()
    spoon.ModalMgr:activate({ "ShowHSHelpKeys" })
end

spoon.ModalMgr.supervisor:enter()
