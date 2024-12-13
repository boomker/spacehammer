---@diagnostic disable: lowercase-global
-- 表情包搜索

require("modules.base")
require("configs.shortcuts")

base_url = "https://www.doutub.com"
local focusedWindow = hs.window.focusedWindow()
if not focusedWindow then return end
local screen = focusedWindow:screen():frame()

-- 占屏幕宽度的 20%（居中）
local WIDTH = 300
local HEIGHT = 300
local CHOOSER_WIDTH = screen.w * 0.2
local COORIDNATE_X = screen.w / 2 + CHOOSER_WIDTH / 2 + 5
local COORIDNATE_Y = screen.h / 2 - 300
emoji_canvas = hs.canvas.new({
    x = COORIDNATE_X,
    y = COORIDNATE_Y - HEIGHT / 2,
    w = WIDTH,
    h = HEIGHT,
})

---@diagnostic disable-next-line: unused-local, unused-function
local function utf8_gsub(str, pattern, repl)
    local result = {}
    local i = 1
    while i <= #str do
        local codepoint = utf8.codepoint(str, i)
        if codepoint then
            local char = utf8.char(codepoint)
            if char:match(pattern) then
                table.insert(result, repl)
            else
                table.insert(result, char)
            end
            i = i + utf8.len(char)
        else
            -- 如果遇到无效的 UTF-8 序列，直接跳过一个字节
            table.insert(result, str:sub(i, i))
            i = i + 1
        end
    end
    return table.concat(result)
end

local function file_exists(file_path)
    local f = io.open(file_path, "r")
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

local function async_download_callback(exitCode, stdOut, stdErr)
    local len = #choices
    if len == 0 then return end
    -- 下载完一张图片，就刷新整个列表（不得已而为之）
    for i = 1, len do
        if choices[i].path then
            local image = hs.image.imageFromPath(choices[i].path)
            if image ~= choices[i].image then
                choices[i].image = image
            end
        end
    end
    chooser:choices(choices)
end

local function download_file(url, file_path)
    if not file_exists(file_path) then
        -- 同步方式下载
        -- hs.execute('curl --header \'Referer: http://kuranado.com\' --request GET ' .. url .. ' --create-dirs -o ' .. file_path)
        -- 异步方式下载
        down_emoji_task = hs.task.new("/usr/bin/curl", async_download_callback, {
            "--header",
            "Referer: " .. base_url,
            url,
            "--create-dirs",
            "-o",
            file_path,
        })
        down_emoji_task:start()
    end
end

local function parse_html(body)
    local htmlparser = require("modules.htmlparser")

    local root = htmlparser.parse(body)

    local sel, response_data, img_urls = root("div.main-content div[class='cell'] > a"), {}, {}
    for _, e in ipairs(sel) do
        local nodes = e.nodes
        for _, n in ipairs(nodes) do
            if n.name == "img" then
                local img_attrs = n.attributes
                local filename, img_url
                for ak, av in pairs(img_attrs) do
                    if ak == "alt" then
                        filename = av
                        -- filename = av and utf8_gsub(av, "[，！？]+", "")
                    elseif ak == "data-src" then
                        if av then img_url = av end
                    end
                    local is_exist = img_url and hs.fnutils.contains(img_urls, img_url)
                    if filename and img_url and not is_exist then
                        table.insert(response_data, { filename, img_url })
                        table.insert(img_urls, filename)
                    end
                end
            end
        end
    end
    return response_data
end

local function preview(path)
    if not path then return end
    emoji_canvas[1] = {
        type = "image",
        image = hs.image.imageFromPath(path),
        imageScaling = "scaleProportionally",
        imageAnimates = true,
    }
    emoji_canvas:show()
end

local function request(query_kw)
    local page = 1
    local req_url = base_url .. "/search/"
    local request_headers = { Referer = base_url }
    local cache_dir = os.getenv("HOME") .. "/.hammerspoon/.emoji/"

    query_kw = trim(query_kw)

    if query_kw == "" then return end

    -- local url = api .. hs.http.encodeForQuery(query) .. "&page=" .. page .. "&size=9"
    local url = req_url .. hs.http.encodeForQuery(query_kw) .. "/" .. page

    hs.http.doAsyncRequest(url, "GET", nil, request_headers, function(code, body, response_headers)
        -- rawjson = hs.json.decode(body)
        local response_data = parse_html(body)
        if code == 200 and response_data then
            raw_len = #response_data
            for _, v in ipairs(response_data) do
                local title = v[1]
                local img_url = v[2]
                -- local file_path = cache_dir .. hs.http.urlParts(v.url).lastPathComponent
                local filename_ext = hs.http.urlParts(img_url).pathExtension
                local file_path = cache_dir .. title .. "." .. filename_ext
                -- 下载图片
                download_file(img_url, file_path)
                table.insert(choices, {
                    text = title,
                    subText = img_url,
                    path = file_path,
                    image = hs.image.imageFromPath(file_path),
                })
            end
            chooser:choices(choices)
        end
    end)
end

chooser = hs.chooser.new(function(selected)
    if selected then
        hs.pasteboard.writeObjects(selected.image)
        hs.eventtap.keyStroke({ "cmd" }, "v")
    end
end)
chooser:width(30)
chooser:rows(10)
chooser:bgDark(false)
chooser:fgColor({ hex = "#000000" })
chooser:placeholderText("搜索表情包")

hs.hotkey.bind(emoji_search.prefix, emoji_search.key, emoji_search.message, function()
    page = 1
    choices = {}
    chooser:show()
    chooser:query("")
end)

-- 上下键选择表情包预览
select_key = hs.eventtap
    .new({ hs.eventtap.event.types.keyDown }, function(event)
        -- 只在 chooser 显示时，才监听键盘按下
        if not chooser:isVisible() then
            return
        end
        local keycode = event:getKeyCode()
        local key = hs.keycodes.map[keycode]
        if "right" == key then
            page = page + 1
            request(chooser:query())
            return
        end
        if "left" == key then
            if page <= 1 then
                page = 1
                return
            end
            page = page - 1
            request(chooser:query())
            return
        end

        if "down" ~= key and "up" ~= key then
            return
        end
        -- TODO-JING 第一项需要直接预览
        number = chooser:selectedRow()
        if "down" == key then
            if number < raw_len then
                number = number + 1
            else
                number = 1
            end
        end
        if "up" == key then
            if number > 1 then
                number = number - 1
            else
                number = raw_len
            end
        end
        row_contents = chooser:selectedRowContents(number)
        preview(row_contents.path)
    end)
    :start()

changed_chooser = chooser:queryChangedCallback(function()
    hs.timer.doAfter(0.1, function()
        page = 1
        choices = {}
        local query = chooser:query()
        request(query)
    end)
end)

hide_chooser = chooser:hideCallback(function()
    emoji_canvas:hide(0.3)
end)
