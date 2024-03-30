---@diagnostic disable: lowercase-global
-- local drawing = require 'hs.drawing'
-- local geometry = require 'hs.geometry'
local canvas = require("hs.canvas")
local screen = require("hs.screen")
local styledtext = require("hs.styledtext")

statusmessage = {}
statusmessage.new = function(messageText)
    ---@diagnostic disable-next-line: redefined-local
    local buildParts = function(messageText)
        local frame = screen.primaryScreen():frame()

        local styledTextAttributes = {
            font = {
                name = "Menlo",
                size = 20,
            },
            color = {
                white = 1,
                alpha = 0.95,
            },
        }

        local styledText = styledtext.new("🤓 > " .. messageText, styledTextAttributes)

        local _text = canvas.new({ x = 0, y = 0, w = 0, h = 0 })
        local styledTextSize = _text:minimumTextSize(styledText)

        -- local styledTextSize = drawing.getTextDrawingSize(styledText)
        text = canvas.new({
            x = frame.w - styledTextSize.w - 40,
            y = frame.h - styledTextSize.h,
            w = styledTextSize.w + 40,
            h = styledTextSize.h + 40,
        })
        text:appendElements({
            id = "msg",
            type = "text",
            text = styledText,
        })

        background = canvas.new({
            x = frame.w - styledTextSize.w - 45,
            y = frame.h - styledTextSize.h - 3,
            w = styledTextSize.w + 15,
            h = styledTextSize.h + 10,
        })
        background:appendElements({
            id = "bg",
            action = "fill",
            type = "rectangle",
            fillColor = { alpha = 0.6, red = 0, green = 0, blue = 0 },
            roundedRectRadii = { xRadius = 6.0, yRadius = 6.0 },
        })

        return background, text
    end

    return {
        _buildParts = buildParts,
        show = function(self)
            self:hide()
            self.background, self.text = self._buildParts(messageText)
            self.background:show()
            self.text:show()
        end,
        hide = function(self)
            if self.background then
                self.background:hide()
                -- self.background:delete()
                self.background = nil
            end
            if self.text then
                self.text:hide()
                -- self.text:delete()
                self.text = nil
            end
        end,
        notify = function(self, seconds)
            local delaySecs = seconds or 0.5
            self:show()
            hs.timer.delayed
                .new(delaySecs, function()
                    self:hide()
                end)
                :start()
        end,
        statusMsgCallback = function()
            -- statusmessage.new(messageText):show()
            oriSM:show()
        end,
        SMWatcher = function(self, toggle)
            -- if toggle == 'on' then
            if toggle == "off" then
                statusMsgWatcher:stop()
            else
                oriSM = toggle
                statusMsgWatcher = hs.spaces.watcher.new(self.statusMsgCallback)
                statusMsgWatcher:start()
            end
        end,
    }
end

return statusmessage
