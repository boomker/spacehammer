---@diagnostic disable: lowercase-global
-- 表情包搜索

require("modules.base")
require("configs.shortcuts")

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
	h = HEIGHT
})

api = "https://www.dbbqb.com/s?w="
request_headers = { Referer = "https://www.dbbqb.com" }
cache_dir = os.getenv("HOME") .. "/.hammerspoon/.emoji/"

choices = {}
page = 1


chooser = hs.chooser.new()
chooser:width(20)
chooser:rows(10)
chooser:bgDark(false)
chooser:fgColor({ hex = "#000000", })
chooser:placeholderText("搜索表情包")

function request(query)
    choices = {}

    query = trim(query)

    if query == "" then return end

    -- local url = api .. hs.http.encodeForQuery(query) .. "&page=" .. page .. "&size=9"
    local url = api .. hs.http.encodeForQuery(query)

	---@diagnostic disable-next-line: unused-local
    hs.http.doAsyncRequest(url, "GET", nil, request_headers, function(code, body, response_headers)
        rawjson = hs.json.decode(body)
        if code == 200 and rawjson.code == 1000 then
            len = #rawjson.data
            for _, v in ipairs(rawjson.data) do
                local file_path = cache_dir .. hs.http.urlParts(v.url).lastPathComponent
                -- 下载图片
                download_file(v.url, file_path)
                table.insert(choices, {
                    text = v.title,
                    subText = v.url,
                    path = file_path,
                    image = hs.image.imageFromPath(file_path),
                })
            end
            chooser:choices(choices)
        end
    end)
end

function download_file(url, file_path)
    if not file_exists(file_path) then
        -- 同步方式下载
        -- hs.execute('curl --header \'Referer: http://kuranado.com\' --request GET ' .. url .. ' --create-dirs -o ' .. file_path)
        -- 异步方式下载
        down_emoji_task = hs.task.new(
            "/usr/bin/curl",
            async_download_callback,
            {
				"--header",
				"Referer: https://www.dbbqb.com",
				url,
				"--create-dirs",
				"-o",
				file_path
			}
        )
        down_emoji_task:start()
    end
end

---@diagnostic disable-next-line: unused-local
function async_download_callback(exitCode, stdOut, stdErr)
    local len = #choices
    if len == 0 then return end
    -- 下载完一张图片，就刷新整个列表（不得已而为之）
    for i = 1, len do
        if choices[i].path ~= nil then
            choices[i].image = hs.image.imageFromPath(choices[i].path)
        end
    end
    chooser:choices(choices)
end

function file_exists(file_path)
    local f = io.open(file_path, "r")
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

function preview(path)
    if path == nil then return end
    emoji_canvas[1] = {
        type = "image",
        image = hs.image.imageFromPath(path),
        imageScaling = "scaleProportionally",
        imageAnimates = true,
    }
    emoji_canvas:show()
end

-- 上下键选择表情包预览
select_key = hs.eventtap
    .new({ hs.eventtap.event.types.keyDown }, function(event)
        -- 只在 chooser 显示时，才监听键盘按下
        if not chooser:isVisible() then return end
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
            if number < len then
                number = number + 1
            else
                number = 1
            end
        end
        if "up" == key then
            if number > 1 then
                number = number - 1
            else
                number = len
            end
        end
        row_contents = chooser:selectedRowContents(number)
        preview(row_contents.path)
    end)
    :start()

hs.hotkey.bind(emoji_search.prefix, emoji_search.key, emoji_search.message, function()
    page = 1
    chooser:query("")
    chooser:show()
end)

changed_chooser = chooser:queryChangedCallback(function()
    hs.timer.doAfter(0.1, function()
        local query = chooser:query()
        page = 1
        request(query)
    end)
end)

hide_chooser = chooser:hideCallback(function()
    emoji_canvas:hide(0.3)
end)
