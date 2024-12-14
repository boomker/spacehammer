---@diagnostic disable: lowercase-global
-- 表情包搜索

require("modules.base")
require("configs.shortcuts")

page = 1
choices = {}
waitlist_render = {}
chooser_raw_len = 0
default_download_tool = "curl" -- or aria2c
base_url = "https://www.doutub.com"
cache_dir = os.getenv("HOME") .. "/.hammerspoon/.emoji/"
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


local function async_download_callback(exitCode, stdOut, stdErr)
    local queue_len = #waitlist_render
    if queue_len == 0 then return end
    local cur_url = waitlist_render[1].subText
    local last_url = (#choices > 0) and choices[#choices].subText or nil
    if (#choices < 1) or (cur_url ~= last_url) then
        table.insert(choices, waitlist_render[1])
        chooser:choices(choices)
        if #choices >= 10 then waitlist_render = {} end

    end
    table.remove(waitlist_render, 1)
end

local function download_file(url, file_path)
    local filename = file_path:gsub(cache_dir, "")
    local save_path = hs.fs.pathToAbsolute(cache_dir)
    local download_tools = {
        ['curl'] = {
            ['path'] = "/usr/bin/curl",
            ['args'] = {
                "--header",
                "Referer: " .. base_url,
                "--connect-timeout",
                "3",
                "-L",
                url,
                "--create-dirs",
                "-o",
                file_path,
            }
        },
        ['aria2c'] = {
            ['path'] = "/usr/local/bin/aria2c",
            ['args'] = {
                "--header=Referer: " .. base_url,
                "--enable-rpc=false",
                "--continue=true",
                "-t",
                "3",
                "-x",
                "3",
                "-s",
                "3",
                "-j",
                "10",
                "-d",
                save_path,
                "-o",
                filename,
                url,
            }
        }
    }
    local exist_ok, err = hs.fs.attributes(file_path)
    if exist_ok then
        async_download_callback()
    else
        -- 异步方式下载
        down_emoji_task = hs.task.new(
            download_tools[default_download_tool]["path"],
            async_download_callback,
            download_tools[default_download_tool]["args"]
        )
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
    waitlist_render = {}
    local req_url = base_url .. "/search/"
    local request_headers = { Referer = base_url }

    query_kw = trim(query_kw)

    if query_kw == "" then return end

    -- local url = api .. hs.http.encodeForQuery(query) .. "&page=" .. page .. "&size=9"
    local url = req_url .. hs.http.encodeForQuery(query_kw) .. "/" .. page

    hs.http.doAsyncRequest(url, "GET", nil, request_headers, function(code, body, response_headers)
        local response_data = parse_html(body)
        if code == 200 and response_data then
            chooser_raw_len = #response_data
            for _, v in ipairs(response_data) do
                local title = v[1]:gsub(" ", "")
                local img_url = v[2]
                local filename_ext = hs.http.urlParts(img_url).pathExtension
                local file_path = cache_dir .. title .. "." .. filename_ext
                table.insert(waitlist_render, {
                    text = title,
                    subText = img_url,
                    path = file_path,
                    image = hs.image.imageFromPath(file_path),
                })
                -- 下载图片
                download_file(img_url, file_path)
            end
        end
    end)
end

local function search_emoji_from_local(query_kw)
    local choices = {}
    local limit_count = 10
    -- local opts = {["except"] = {query_kw}}
    local filelist, filecount, _dircount = hs.fs.fileListForPath(cache_dir)
    if filecount == 0 then return false end
    chooser_raw_len = (filecount > 10) and 10 or filecount
    local start_index = (page > 1) and ((page - 1) * 10) or 0
    for i, _f in ipairs(filelist) do
        -- for i = start_index, filecount do
        local file_path = filelist[i]
        local filename = hs.fs.displayName(file_path)
        local filename_ext = string.match(filename, "^.+%.([^%.]+)$")
        local short_fn = filename:gsub("." .. filename_ext, "")
        if short_fn:find(trim(query_kw)) then
            if start_index > 0 then
                start_index = start_index - 1
                goto SKIP_LAST_PAGE
            end
            table.insert(choices, {
                text = short_fn,
                subText = "",
                path = file_path,
                image = hs.image.imageFromPath(file_path),
            })
            limit_count = limit_count - 1
            if limit_count == 0 then break end
            ::SKIP_LAST_PAGE::
        end
    end
    chooser:choices(choices)
    if limit_count == 0 then return true end
end

chooser = hs.chooser.new(function(selected)
    if selected then
        local image = hs.image.imageFromPath(selected.path)
        hs.pasteboard.writeObjects(image)
        hs.eventtap.keyStroke({ "cmd" }, "v")
    end
end)
chooser:width(30)
chooser:rows(10)
chooser:bgDark(false)
chooser:fgColor({ hex = "#000000" })
chooser:placeholderText("输入关键词搜索表情包")

-- 上下键选择表情包预览
select_key = hs.eventtap
    .new({ hs.eventtap.event.types.keyDown }, function(event)
        -- 只在 chooser 显示时，才监听键盘按下
        if not chooser:isVisible() then return end
        local keycode = event:getKeyCode()
        local key = hs.keycodes.map[keycode]
        if "right" == key then
            page = page + 1
            local query = chooser:query()
            local exist_local = search_emoji_from_local(query)
            if not exist_local then
                choices = {}
                request(chooser:query())
            end
            return
        end
        if "left" == key then
            if page <= 1 then
                page = 1
                return
            end
            page = page - 1
            local exist_local = search_emoji_from_local(chooser:query())
            if not exist_local then request(chooser:query()) end
            return
        end

        if "down" ~= key and "up" ~= key then return end
        number = chooser:selectedRow()
        if "down" == key then
            if number < chooser_raw_len then
                number = number + 1
            else
                number = 1
            end
        end
        if "up" == key then
            if number > 1 then
                number = number - 1
            else
                number = chooser_raw_len
            end
        end
        row_contents = chooser:selectedRowContents(number)
        preview(row_contents.path)
    end)
    :start()

changed_chooser = chooser:queryChangedCallback(function()
    hs.timer.doAfter(0.2, function()
        local query = chooser:query()
        local exist_local = search_emoji_from_local(query)
        if not exist_local then
            page = 1
            choices = {}
            request(query)
        end
    end)
end)

hide_chooser = chooser:hideCallback(function()
    emoji_canvas:hide(0.3)
end)

hs.hotkey.bind(emoji_search.prefix, emoji_search.key, emoji_search.message, function()
    chooser:show()
    chooser:query("")
end)
