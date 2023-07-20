--- === Layouts ====
--
-- Provides the ability to save desktop layouts
-- Derivative of ArrangeDesktop spoon
-- inspired by Evan Travers blog on Window Layouts/Headspace
--
--

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Layouts"
obj.version = "1.0"
obj.author = "Hiren Hindocha <hiren.hindocha+github@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- Layouts.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the
-- messages coming from the Spoon.
obj.logger = hs.logger.new('Layouts')
-- obj.logger.setLogLevel('debug')
obj.layouts = {}

local menu = nil
-- local lastApp = nil
-- local chooser = nil
-- local visible = false


function obj:_layouts2File()
    if not hs.fs.pathToAbsolute("~/.hammerspoon/layouts.json") then
        local retCode = io.open(hs.fs.pathToAbsolute("~") .. "/.hammerspoon/layouts.json", 'w+')
        if not retCode then
            return
        end
    end
    local lf     = io.open(hs.fs.pathToAbsolute("~/.hammerspoon/layouts.json"), 'w')
    --    result = hs.json.encode(obj.layouts)
    local result = hs.json.encode(obj.layouts, true)
    if lf then
        lf:write(result)
        lf:close()
    end
end

-- callback when the menubar icon is clicked.
local function menuClickCallback(mods)
    local menuItems = {}
    table.insert(menuItems, { title = "Save Current Desktop Layout", fn = function() obj:saveLayout() end })

    if obj.layouts ~= nil then
        for k, v in pairs(obj.layouts) do
            obj.logger.df(k, v)
            local function menuItemClickCallback(itemmods)
                if itemmods.ctrl then
                    obj:removeLayout(k)
                else
                    obj.logger.df(hs.inspect(obj.layouts))
                    obj.logger.df('k = ' .. k)
                    -- obj.hideAll(nil)
                    hs.timer.doAfter(0.5, function() obj:arrange(k) end)
                    --            obj:arrange(k)
                end
            end

            table.insert(menuItems, { title = "Use " .. k .. " Layout", fn = menuItemClickCallback })
        end
    else
        obj.logger.df('obj.layouts is NIL, it should not be')
    end
    obj.logger.df('Printing menuItems in menuClickCallback')
    obj.logger.df(hs.inspect(menuItems))
    return menuItems
end

function obj:hideAll()
    local s = [[
    tell application "Finder"
        set visible of every process whose visible is true and name is not "Finder" to false
        set the collapsed of windows to true
    end tell
    ]]

    return hs.osascript.applescript(s)
    --    timing is off using BTT, it hides the new layout as well
    --    local ok = hs.urlevent.openURL('btt://trigger_named/?trigger_name=hideAll')

end

-- allow the user to delete a layout
function obj:removeLayout(layout_nm)
    self.layouts[layout_nm] = nil
    self:_layouts2File()
end

function obj:getLayoutName()
    hs.focus()
    local button, layout_nm = hs.dialog.textPrompt("Enter Layout Name",
        "Please enter layout name", "Eg- Home Office", "OK", "Cancel")
    if button == "OK" then
        obj.logger.df(layout_nm)
    end
    return layout_nm
end

function obj:chooseLayout(otherWindowGroupLayouts)
    local choices = {}
    self:loadLayout()
    for k, _ in pairs(self.layouts) do
        table.insert(choices,
            { text = k,
                subtext = "Choose a layout"
            })
    end
    if otherWindowGroupLayouts then
        for j, _ in pairs(otherWindowGroupLayouts) do
            table.insert(choices,
                {
                    text = j,
                    subtext = ""
                })
        end
    end
    local chooser = hs.chooser.new(function(choice)
        if not choice then obj.logger.df("No choice made"); return end
        -- obj.logger.df(hs.inspect(choice))
        -- obj.logger.df(choice.text)
        -- obj.hideAll(nil)
        if choice.subtext then
            hs.timer.doAfter(0.5, hs.fnutils.partial(self.arrange, self, choice.text))
        else
            hs.timer.doAfter(0.5, function ()
                hs.mjomatic.go(otherWindowGroupLayouts[choice.text])
            end)
        end
    end)

    chooser:placeholderText('搜索窗口组布局')
    chooser:searchSubText(true)
    chooser:choices(choices)
    chooser:show()
end

function obj:positionApp(app, appTitle, monitorUUID, frame)

    --    local windows = hs.window.filter.new(appTitle):getWindows()
    local windows = app:allWindows()
    if (#windows < #frame) then
        obj.logger.df("More windows for " .. appTitle .. " than in our layout")
    end

    --    We need to do some sanity checks
    --    Check to see if the frame size is within the Screen size bounds
    --    Ignore the positioning if that is the case.
    --    When saving layouts, we are getting Finder window size that is the
    --    size of both the monitors.
    local screen = hs.screen(monitorUUID)
    --    obj.logger.df(hs.inspect(screen:fullFrame()))
    local sf = screen:fullFrame().table
    local sf_h = sf['h']
    local sf_w = sf['w']
    for ix, v in ipairs(windows) do
        if ix > #frame then
            obj.logger.df('we have more windows than what we have saved ')
            break
        end
        --        obj.logger.df(appTitle .. ix .. hs.inspect(v))
        local app_frame_h = frame[ix]['h']
        local app_frame_w = frame[ix]['w']
        if (app_frame_h < sf_h) and (app_frame_w < sf_w) then
            app:activate()
            v:moveToScreen(monitorUUID)
            v:setFrame(frame[ix], 0.5)
            obj.logger.df('Setting frame for ' .. appTitle)
            obj.logger.df('ix = ' .. ix)
            obj.logger.df('frame = ' .. hs.inspect(frame[ix]))
        else
            obj.logger.df('Invalid frame size' .. hs.inspect(frame[ix]))
        end

    end
end

function obj:arrange(arrangement)
    obj.logger.df('in arrange ' .. arrangement)
    --    self:hideAll()
    for monitorUUID, monitorDetails in pairs(self.layouts[arrangement]) do
        if hs.screen.find(monitorUUID) ~= nil then
            for appName, position in pairs(monitorDetails['apps']) do
                --                obj.logger.df(appName .. hs.inspect(position))
                hs.application.launchOrFocus(appName)
                local app = hs.application.get(appName)
                if app ~= nil then
                    obj.logger.df(appName, monitorUUID, hs.inspect(position))
                    self:positionApp(app, appName, monitorUUID, position)
                end
            end
        end
    end
end

function obj:loadLayout()
    if not hs.fs.pathToAbsolute("~/.hammerspoon/layouts.json") then return end
    local f = io.open(hs.fs.pathToAbsolute("~/.hammerspoon/layouts.json"), 'r')
    if f ~= nil then
        local readjson = f:read("*a")
        self.layouts = hs.json.decode(readjson)
        f:close()
    end
    obj.logger.df(hs.inspect(self.layouts))

end

function obj:saveLayout()


    --     global for now as I want to view this in the console
    local screens = {}
    --    layouts['Home Office'] = screens
    --
    local layout_nm = self:getLayoutName()
    if self.layouts == nil then
        self.layouts = {}
    end
    self.layouts[layout_nm] = screens
    for k, v in pairs(hs.screen.allScreens()) do
        local apps = {}
        local screen = {}
        screens[v:getUUID()] = screen
        screen['Monitor Name'] = v:name()
        screen['apps'] = apps

        --        local windows = hs.window.filter.new(true):setScreens(v:getUUID()):getWindows()
        local windows = hs.window.visibleWindows()
        --      local wf = hs.window.filter
        --      allowScreens
        --        local windows = wf.new{override={visible=true,allowScreens=v:name(),
        --                            fullscreen=false,currentSpace=true}}:getWindows()
        for wi, wv in pairs(windows) do
            -- local frame = frameTemplate

            if (wv:isVisible()) and (wv:screen():name() == v:name()) then
                --                wv:focus()
                local t = wv:application():title()
                if apps[t] == nil then
                    apps[t] = { wv:frame().table }
                    --                apps[wv:application():title()] = wv:frame().table
                    --                we have multiple windows for the same app
                else
                    table.insert(apps[t], wv:frame().table)
                end

            end
        end
    end

    self:_layouts2File()
end

function obj:init()
    self:loadLayout()
    return self
end

function obj:start()
    menu = hs.menubar.new()
    menu:setIcon(hs.image.imageFromName("NSHandCursor"))
    menu:setMenu(menuClickCallback)
    return self
end

--- Layouts:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Layouts Chooser
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the chooser
---
--- Returns:
---  * The Layouts object
function obj:bindHotKeys(mapping)
    local spec = {
        choose = hs.fnutils.partial(self.chooseLayout, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

-- This will allow us to invoke the functions using URLcallbacks
-- like hammerspoon://layouts?layout=nm
-- actions can be
-- layout
hs.urlevent.bind("layouts", function(eventName, params)
    local action = params['layout']
    obj.logger.df('Received Layouts ' .. action)
    if (obj.layouts ~= nil) and (obj.layouts[action] ~= nil) then
        obj:arrange(action)
    else
        hs.alert("No Layouts named '" .. action .. "' found")
    end
end)


return obj
