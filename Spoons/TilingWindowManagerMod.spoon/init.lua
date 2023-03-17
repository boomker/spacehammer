---@diagnostic disable: unused-local, redefined-local, lowercase-global
--- === TilingWindowManager ===
---
--- macOS Tiling Window Manager. Spoon on top of Hammerspoon.
---
--- Example `~/.hammerspoon/init.lua` configuration:
---
--- ```
--- hs.loadSpoon("TilingWindowManager")
---     :setLogLevel("debug")
---     :bindHotkeys({
---         tile =           {hyper, "t"},
---         incMainRatio =   {hyper, "p"},
---         decMainRatio =   {hyper, "o"},
---         incMainWindows = {hyper, "i"},
---         decMainWindows = {hyper, "u"},
---         focusNext =      {hyper, "k"},
---         focusPrev =      {hyper, "j"},
---         swapNext =       {hyper, "l"},
---         swapPrev =       {hyper, "h"},
---         toggleFirst =    {hyper, "return"},
---         tall =           {hyper, ","},
---         talltwo =        {hyper, "m"},
---         fullscreen =     {hyper, "."},
---         wide =           {hyper, "-"},
---         display =        {hyper, "d"},
---     })
---     :start({
---         menubar = true,
---         dynamic = true,
---         layouts = {
---             spoon.TilingWindowManager.layouts.fullscreen,
---             spoon.TilingWindowManager.layouts.tall,
---             spoon.TilingWindowManager.layouts.talltwo,
---             spoon.TilingWindowManager.layouts.wide,
---             spoon.TilingWindowManager.layouts.floating,
---         },
---         displayLayout = true,
---         floatApps = {
---             "com.apple.systempreferences",
---             "com.apple.ActivityMonitor",
---             "com.apple.Stickies",
---         }
---     })
--- ```

local inspect  = require("hs.inspect")
local window   = require("hs.window")
local fnutils  = require("hs.fnutils")
local spoons   = require("hs.spoons")
local settings = require("hs.settings")
local menubar  = require("hs.menubar")
-- local image =      require("hs.image")

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "TilingWindowManager"
obj.version = "0.0"
obj.author = "B Viefhues"
obj.homepage = "https://github.com/bviefhues/TilingWindowManager.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"


-- Variables --------------------------------------------------------

-- Internal: TilingWindowManager.log
-- Variable
-- Logger object used within the Spoon. Can be accessed to set
-- the default log level for the messages coming from the Spoon.
obj.log = hs.logger.new("TilingWindowManager")

-- Internal: TilingWindowManager.menubar
-- Variable
-- Contains the Spoons hs.menubar.
obj.menubar = nil

-- Internal: TilingWindowManager.spacesWatcher
-- Variable
-- Contains a hs.spaces.watcher for the Spoon to get notified on
-- macOS space changes.
obj.spacesWatcher = nil

-- Internal: TilingWindowManager.windowFilter
-- Variable
-- Contains a hs.window.filter subscription for the Spoon to get
-- notified on macOS window changes.
obj.windowFilter = nil

-- Internal: TilingWindowManager.tilingConfig
-- Variable
-- Table maintaining the tiling configuration per space. Key is the space
-- ID as returned by hs.spaces.focusedSpace(), value is a config table
-- initialized by TilingWindowManager.initTilingConfig()
obj.tilingConfig = {}

--- TilingWindowManager.layouts
--- Variable
--- A table holding all known tiling layouts. Maps keys to descriptive strings. The strings show up in the user interface.
obj.layouts = {
    floating = "Floating",
    fullscreen = "Fullscreen",
    tall = "Tall",
    wide = "Wide",
    talltwo = "Tall Two Pane"
}

-- TilingWindowManager.enabledLayouts
-- Variable
-- A table holding all enabled tiling layouts.
--
-- Notes:
-- Can be set as a config option in the spoons `start()` method.
-- Default: `TilingWindowManager.layouts.floating`

obj.enabledLayouts = { obj.layouts.floating }

-- TilingWindowManager.fullscreenRightApps
-- Variable
-- A table holding names of applications which shall be positioned on right half of screen only for fullscreen layout.
--
-- Notes:
-- Can be set as a config option in the spoons `start()` method.
obj.fullscreenRightApps = {}

-- TilingWindowManager.floatApps
-- Variable
-- A table holding bundleID's of applications which shall not be tiled.
--
-- Notes:
-- * These application's windows are never modified by the spoon.
-- * Can be set as a config option in the spoons `start()` method.
obj.floatApps = {}

-- TilingWindowManager.displayLayoutOnLayoutChange
-- Variable
-- If true: show `hs.alert()` with layout name when changing layout.
--
-- Notes:
-- Can be set as a config option in the spoons `start()` method.
obj.displayLayoutOnLayoutChange = false


-- Tiling strategy --------------------------------------------------

-- TilingWindowManager.tilingStrategy
-- Variable
-- A table holding everything necessary for each layout.
--
-- Notes:
-- The table key is a tiling layout, as per
-- `TilingWindowManager.layouts`.
--
-- The table value for each layout is a table with these keys:
--  * tile(windows) - a function to move windows in place.
--  * symbol - a string formatted as ASCII image, the layouts icon.
obj.tilingStrategy = {}

obj.tilingStrategy[obj.layouts.floating] = {
    tile = function(tilingConfig)
        obj.log.d("> tile", hs.inspect(tilingConfig))
        -- do nothing
        obj.log.d("< tile")
    end,

    symbol = [[ASCII:
. . . . . . . . . . . . . . . . . . . . .
. . D E # # # # # # # # # E F . . . . . .
. D H # # # # # # # # # # # H F . . . . .
. C . . . . . . . . . . . . . G . . . . .
. # . . . . h a # # # # # # # # # a b . .
. # . . . h i # # # # # # # # # # # i b .
. # . . . g . . . . . . . . . . . . . c .
. # . . . # . . . . . . . . . . . . . # .
. C . . . # . . . . . . . . . . . . . # .
. B . . . # . . . . . . . . . . . . . # .
. . B A A # . . . . . . . . . . . . . # .
. . . . . g . . . . . . . . . . . . . c .
. . . . . f . . . . . . . . . . . . . d .
. . . . . . f e # # # # # # # # # e d . .
. . . . . . . . . . . . . . . . . . . . .
]],
}

obj.tilingStrategy[obj.layouts.fullscreen] = {
    tile = function(tilingConfig)
        obj.log.d("> tile", hs.inspect(tilingConfig))
        for i, window in ipairs(tilingConfig.windows) do
            local frame = window:screen():frame()
            -- Keep some apps on right side only
            -- Old habit...
            local appBundleID = window:application():bundleID()
            if fnutils.contains(obj.fullscreenRightApps, appBundleID) then
                local mainRatio = tilingConfig.mainRatio or 0.5
                frame.x = frame.x + (frame.w * mainRatio)
                frame.w = frame.w * (1 - mainRatio)
            end
            window:setFrame(frame)
        end
        obj.log.d("< tile", obj.layouts.fullscreen)
    end,

    symbol = [[ASCII:
. . . . . . . . . . . . . . . . . . . . .
. . h a # # # # # # # # # # # # # a b . .
. h A # # # # # # # # # # # # # # # B b .
. g . . . . . . . . . . . . . . . . . c .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. g . . . . . . . . . . . . . . . . . c .
. f . . . . . . . . . . . . . . . . . d .
. . f e # # # # # # # # # # # # # e d . .
. . . . . . . . . . . . . . . . . . . . .
]],
}

obj.tilingStrategy[obj.layouts.tall] = {
    tile = function(tilingConfig)
        obj.log.d("> tile", hs.inspect(tilingConfig))
        local windows = tilingConfig.windows

        if #windows > 0 then
            local mainNumberWindows = math.min(
                tilingConfig.mainNumberWindows or 1,
                #tilingConfig.windows)
            local stackNumberWindows = 0
            local mainRatio = 1
            if #windows > mainNumberWindows then -- check if stack
                mainRatio = tilingConfig.mainRatio or 0.5
                stackNumberWindows = #windows - mainNumberWindows
            end

            for i, window in ipairs(windows) do
                local frame = window:screen():frame()
                if i <= tilingConfig.mainNumberWindows then -- main
                    frame.w = frame.w * mainRatio
                    frame.h = frame.h / mainNumberWindows
                    frame.y = frame.y + frame.h * (i - 1)
                else -- stack
                    frame.x = frame.x + (frame.w * mainRatio)
                    frame.h = frame.h / stackNumberWindows
                    frame.y = frame.y +
                        frame.h * (i - mainNumberWindows - 1)
                    frame.w = frame.w * (1 - mainRatio)
                end
                window:setFrame(frame)
            end
        end
        obj.log.d("< tile")
    end,

    symbol = [[ASCII:
. . . . . . . . . . . . . . . . . . . . .
. . h a # # # # # # # # # # # # # a b . .
. h 2 # # # # # # 2 1 3 # # # # # # 3 b .
. g . . . . . . . . # . . . . . . . . c .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # 4 # # # # # # 4 # .
. # . . . . . . . . # 5 # # # # # # 5 # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # 6 # # # # # # 6 # .
. # . . . . . . . . # 7 # # # # # # 7 # .
. g . . . . . . . . # . . . . . . . . c .
. f . . . . . . . . 1 . . . . . . . . d .
. . f e # # # # # # # # # # # # # e d . .
. . . . . . . . . . . . . . . . . . . . .
]],
}

obj.tilingStrategy[obj.layouts.talltwo] = {
    tile = function(tilingConfig)
        obj.log.d("> tile", hs.inspect(tilingConfig))
        local windows = tilingConfig.windows

        if #windows > 0 then
            local mainNumberWindows = math.min(
                tilingConfig.mainNumberWindows or 1,
                #windows)
            local stackNumberWindows = 0
            local mainRatio = 1
            if #windows > mainNumberWindows then -- check if stack
                mainRatio = tilingConfig.mainRatio or 0.5
                stackNumberWindows = #windows - mainNumberWindows
            end

            for i, window in ipairs(windows) do
                local frame = window:screen():frame()
                if i <= tilingConfig.mainNumberWindows then -- main
                    frame.w = frame.w * mainRatio
                    frame.h = frame.h / mainNumberWindows
                    frame.y = frame.y + frame.h * (i - 1)
                else -- stack
                    frame.x = frame.x + (frame.w * mainRatio)
                    frame.h = frame.h
                    frame.y = frame.y
                    frame.w = frame.w * (1 - mainRatio)
                end
                window:setFrame(frame)
            end
        end
        obj.log.d("< tile")
    end,

    symbol = [[ASCII:
. . . . . . . . . . . . . . . . . . . . .
. . h a # # # # # # # # # # # # # a b . .
. h 2 # # # # # # 2 1 3 # # # # # # 3 b .
. g . . . . . . . . # . . . . . . . . c .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. # . . . . . . . . # . . . . . . . . # .
. g . . . . . . . . # . . . . . . . . c .
. f . . . . . . . . 1 . . . . . . . . d .
. . f e # # # # # # # # # # # # # e d . .
. . . . . . . . . . . . . . . . . . . . .
]],
}

obj.tilingStrategy[obj.layouts.wide] = {
    tile = function(tilingConfig)
        obj.log.d("> tile", hs.inspect(tilingConfig))
        local windows = tilingConfig.windows

        if #windows > 0 then
            local mainNumberWindows = math.min(
                tilingConfig.mainNumberWindows or 1,
                #windows)
            local stackNumberWindows = 0
            local mainRatio = 1
            if #windows > mainNumberWindows then -- check if stack
                mainRatio = tilingConfig.mainRatio or 0.5
                stackNumberWindows = #windows - mainNumberWindows
            end

            for i, window in ipairs(windows) do
                local frame = window:screen():frame()
                if i <= tilingConfig.mainNumberWindows then -- main
                    frame.h = frame.h * mainRatio
                    frame.w = frame.w / mainNumberWindows
                    frame.x = frame.x + frame.w * (i - 1)
                else -- stack
                    frame.y = frame.y + (frame.h * mainRatio)
                    frame.w = frame.w / stackNumberWindows
                    frame.x = frame.x +
                        frame.w * (i - mainNumberWindows - 1)
                    frame.h = frame.h * (1 - mainRatio)
                end
                window:setFrame(frame)
            end
        end
        obj.log.d("< tile")
    end,

    symbol = [[ASCII:
. . . . . . . . . . . . . . . . . . . . .
. . h a # # # # # # # # # # # # # a b . .
. h 1 # # # # # # # # # # # # # # # 1 b .
. g . . . . . . . . . . . . . . . . . c .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # . . . . . . . . . . . . . . . . . # .
. # 2 # # # # # # # # # # # # # # # 2 # .
. # 3 # # # # # # # # # # # # # # # 3 # .
. # . . . . . 4 . . . . . 5 . . . . . # .
. # . . . . . # . . . . . # . . . . . # .
. g . . . . . # . . . . . # . . . . . c .
. f . . . . . 4 . . . . . 5 . . . . . d .
. . f e # # # # # # # # # # # # # e d . .
. . . . . . . . . . . . . . . . . . . . .
]],
}


-- Tiling Config ------------------------------------------------------

-- Internal: Save tiling config to keep them across hammerspoon reloads
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function obj.saveTilingConfig()
    obj.log.d("> saveTilingConfig")
    local saveTilingConfig = {}
    for k1, v1 in pairs(obj.tilingConfig) do
        saveTilingConfig[k1] = {}
        for k2, v2 in pairs(v1) do
            if type(v2) ~= "table" then -- everything except window list
                saveTilingConfig[k1][k2] = v2
            end
        end
    end
    --obj.log.d("saveTilingConfig", hs.inspect(saveTilingConfig))
    settings.clear(obj.name)
    settings.set(obj.name, saveTilingConfig)
    obj.log.d("< saveTilingConfig")
end

-- Internal: Load tiling config and merge with existing tiling config
--
-- Parameters:
--  * None
--
-- Returns:
--  * none
function obj.loadTilingConfig()
    obj.log.d("> loadTilingConfig")
    local allSpaces = {} -- to deflate screens and prepare lookup
    for screen, spaces in pairs(hs.spaces.allSpaces()) do
        for k, space in pairs(spaces) do
            allSpaces[tostring(space)] = true
        end
    end

    local settingsData = settings.get(obj.name)

    for space, config in pairs(settingsData) do
        if obj.tilingConfig[space] == nil then -- is not known
            if allSpaces[space] ~= nil then -- is actually a current space
                --  start with known clean config
                obj.tilingConfig[space] = obj.initTilingConfig()
                -- overwrite loaded config parameters
                for k, v in pairs(config) do
                    obj.tilingConfig[space][k] = v
                end
            end
        end
    end
    obj.log.d("< loadTilingConfig")
end

-- Internal: generate default tiling config structure for a space.
--
-- Parameters:
--  * None
--
-- Returns
--  * Table with default tiling config structure
function obj.initTilingConfig()
    local tilingConfig = {}
    tilingConfig.layout = obj.enabledLayouts[1]
    tilingConfig.windows = {} -- windows in tiling order
    tilingConfig.mainNumberWindows = 1
    tilingConfig.mainRatio = 0.5
    return tilingConfig
end

-- Tiling management ------------------------------------------------

-- Internal: Helper function to log a table of window objects to the
-- console, including some relevant window attributes. Useful for
-- debugging.
--
-- Parameters:
--  * text - written to console to identify output
--  * windows - a table of `hs.windows` objects.
--
-- Returns:
--  * None
function obj.logWindows(text, windows)
    obj.log.d(text)
    if windows then
        for i, w in ipairs(windows) do
            obj.log.d("  ", i,
                "ID:" .. w:id(),
                "V:" .. tostring(w:isVisible()):sub(1, 1),
                "S:" .. tostring(w:isStandard()):sub(1, 1),
                "M:" .. tostring(w:isMinimized()):sub(1, 1),
                "(" .. w:title():sub(1, 25) .. ")")
        end
    else
        obj.log.d("  no windows")
    end
end

-- Internal: Sets the tiling config of the current space.
--
-- Parameters:
--  * layout - String as per `obj.enabledLayouts`
--
-- Returns:
--  * tiling config - table as per `obj.initTilingConfig()`
function obj.setLayoutCurrentSpace(layout)
    obj.log.d("> setLayoutCurrentSpace", layout)
    local tilingConfig = obj.tilingConfigCurrentSpace()

    if fnutils.contains(obj.enabledLayouts, layout) then
        tilingConfig.layout = layout
    else
        obj.log.d("  Tiling layout not enabled:", layout)
    end

    if obj.displayLayoutOnLayoutChange then
        obj.displayLayout(tilingConfig)
    end

    obj.saveTilingConfig()
    obj.log.d("< setLayoutCurrentSpace")
    return tilingConfig
end

-- Internal: change the ratio between main and stack.
--
-- Parameters:
--  * ratio - relative ratio, negative makes main smaller, positive
--            makes main larger. Since ratio is between 0.2 and 0.8,
--            argument should be a fractional value.
--
-- Returns:
--  * none
function obj.setMainRatioRelative(ratio)
    obj.log.d("> setMainRatioRelative", ratio)
    local tilingConfig = obj.tilingConfigCurrentSpace()

    tilingConfig.mainRatio = tilingConfig.mainRatio + ratio
    if tilingConfig.mainRatio < 0.2 then
        tilingConfig.mainRatio = 0.2
    end
    if tilingConfig.mainRatio > 0.8 then
        tilingConfig.mainRatio = 0.8
    end
    obj.saveTilingConfig()
    obj.log.d("> setMainRatioRelative")
end

-- Internal: change the number of main windows.
--
-- Parameters:
--  * i - relative window number change, negative lowers number of
--        main windows, positive increases number of main windows,
--        number of windows is capped between 1 and 10, argument
--        should likely be either -1 or 1.
--
-- Returns:
--  * none
function obj.setMainWindowsRelative(i)
    obj.log.d("> setMainWindowsRelative", i)
    local tilingConfig = obj.tilingConfigCurrentSpace()
    tilingConfig.mainNumberWindows = tilingConfig.mainNumberWindows + i
    if tilingConfig.mainNumberWindows < 1 then
        tilingConfig.mainNumberWindows = 1
    end
    if tilingConfig.mainNumberWindows > 10 then
        tilingConfig.mainNumberWindows = 10
    end
    obj.saveTilingConfig()
    obj.log.d("> setMainRatioRelative")
end

-- Internal: Returns the tiling configuration for the
-- current space. Preserves the order of known windows and combines with
-- any newly visible windows in the space, e.g. through un-minimizing.
--
-- This is the place where any automatic arranging or ordering of windows
-- happens.
--
-- Parameters:
--  * evalWindows - if True: force recalculating the window order
--
-- Returns:
--  * A table with tiling config information
function obj.tilingConfigCurrentSpace(evalWindows)
    obj.log.d("> tilingConfigCurrentSpace")

    local spaceID = tostring(hs.spaces.focusedSpace())
    --obj.log.d("spaceID = ", spaceID)
    local tilingConfig = obj.tilingConfig[spaceID]

    if tilingConfig == nil then
        obj.log.d("creating new tilingConfig")
        tilingConfig = obj.initTilingConfig()
    end

    if evalWindows then
        local visibleWindows = fnutils.filter(hs.window.orderedWindows(),
            -- ordered windows to pick backmost window for tilingConfig
            function(w)
                local focusedWindow = hs.window.focusedWindow()
                if focusedWindow then
                    return (
                        w:isVisible()
                            and w:isStandard()
                            and (not w:isMinimized())
                            -- only windows on current screen, otherwise will
                            -- mingle windows from all screens
                            and w:screen() == focusedWindow:screen()
                        )
                else
                    return (
                        w:isVisible()
                            and w:isStandard()
                            and (not w:isMinimized())
                        )
                end
            end)

        -- filter window config for currently visible windows only
        local knownWindows = fnutils.filter(tilingConfig.windows,
            function(w)
                return fnutils.contains(visibleWindows, w)
            end)
        -- Windows which are new, we don't know the order of
        local newWindows = fnutils.filter(visibleWindows, function(w)
            return (not fnutils.contains(tilingConfig.windows, w))
        end)
        -- sort by window position to maintain order across Hammerspoon
        -- restarts.
        table.sort(newWindows, function(w1, w2)
            f1 = w1:frame()
            f2 = w2:frame()
            return (f1.x + f1.y) < (f2.x + f2.y)
        end)
        -- Add new windows to ordered windows
        -- This adds new windows at beginning, i.e. replaces the main
        -- pane.
        local tileableWindows = fnutils.concat(
            newWindows,
            knownWindows)
        -- filter out configured "always float" app windows
        local tilingWindows = fnutils.filter(tileableWindows, function(w)
            return (not fnutils.contains(
                obj.floatApps,
                w:application():bundleID()))
        end)

        tilingConfig.windows = tilingWindows
    end

    -- save tiling config for later re-use
    obj.tilingConfig[spaceID] = tilingConfig

    obj.log.d("< tilingConfigCurrentSpace")
    return tilingConfig
end

-- Internal: tiles the current macOS space, i.e. re-arranges windows
-- according to the selected layout for that space.
--
-- Parameters:
--  * windows - a table of windows to tile, this is optional to help
--    avoiding calculating the window table several times. The calling
--    code can pass this if it knows that table already. Will be
--    calculated in the method if `nil`.
--
-- Returns:
--  * None
--
-- Notes:
-- This calls the `tile()` function of `tilingStrategy`.
function obj.tileCurrentSpace(evalWindows)
    obj.log.d("> tileCurrentSpace", hs.inspect(evalWindows))
    local tilingConfig = obj.tilingConfigCurrentSpace(evalWindows)
    obj.tilingStrategy[tilingConfig.layout].tile(tilingConfig)
    obj.log.d("< tileCurrentSpace")
end

-- Internal: Callback for hs.spaces.watcher, is triggered when
-- user switches to another space, tiles space and updates menu.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function obj.switchedToSpace(number)
    obj.log.d("> switchedToSpace", number)
    obj.tileCurrentSpace(true) -- in case window configuration has changed
    obj.updateMenu()
    obj.log.d("< switchedToSpace")
end

-- Move focus and swap windows --------------------------------------

--- TilingWindowManager.focusRelative(relativeIndex) -> nil
--- Function
--- Change window focus.
---
--- Parameters:
---  * relativeIndex - positive moves focus next, negative moves
---    focus previous.
---
--- Returns:
---  * None
---
--- Notes:
--- Newly focussed window is determined by relative distance `relativeIndex` from current window in ordered tileable windows table.  Wraps around if current window is first or last window.
--- `+1` focuses next window, `-1` focuses previous window.
function obj.focusRelative(relativeIndex)
    obj.log.d("> focusRelative", relativeIndex)
    local windows = obj.tilingConfigCurrentSpace().windows
    if #windows > 1 then
        local i = fnutils.indexOf(windows, window.focusedWindow())
        if i then
            -- offset the table starting with 1 index for modulo
            local j = (i - 1 + relativeIndex) % #windows + 1
            windows[j]:focus():raise()
        else
            obj.log.d("Window is floating")
        end
    end
    obj.log.d("< focusRelative")
end

--- TilingWindowManager.moveRelative(relativeIndex) -> nil
--- Function
--- Moves window to different position in table of tileable windows.
---
--- Parameters:
---  * relativeIndex - positive moves window next, negative moves
---    window previous.
---
--- Returns:
---  * None
---
--- Notes:
--- Wraps around if current window is first or last window.
--- Tiles the current space.
function obj.moveRelative(relativeIndex)
    obj.log.d("> moveRelative", relativeIndex)
    local windows = obj.tilingConfigCurrentSpace().windows
    if #windows > 1 then
        local i = fnutils.indexOf(windows, window.focusedWindow())
        if i then
            -- offset the table starting with 1 index for modulo
            local j = (i - 1 + relativeIndex) % #windows + 1
            windows[i], windows[j] = windows[j], windows[i]
            obj.tileCurrentSpace(windows)
        else
            obj.log.d("Window is floating")
        end
    end
    obj.log.d("< swapNext")
end

--- TilingWindowManager.swapFirst() -> nil
--- Function
--- Swaps first window.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
--- If current window is first window: Swaps window order and position with second window in tileable windows.
--- If current window is not first window: Swaps window order and position with first window in tileable windows.
--- Tiles the current space.
function obj.swapFirst()
    obj.log.d("> swapFirst")
    local windows = obj.tilingConfigCurrentSpace().windows
    if #windows > 1 then
        local i = fnutils.indexOf(windows, window.focusedWindow())
        if i then
            if i == 1 then
                obj.moveRelative(1)
            elseif i > 1 then
                windows[i], windows[1] = windows[1], windows[i]
                obj.tileCurrentSpace(windows)
            end
        else
            obj.log.d("Window is floating")
        end
    end
    obj.log.d("< swapFirst")
end

--- TilingWindowManager.toggleFirst() -> nil
--- Function
--- Toggles first window.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * If current window is first window: Swaps window order and position with second window in tileable windows.
---  * If current window is not first window: Makes current window the first window. Previous first window becomes the second window.
---  *Tiles the current space.
function obj.toggleFirst()
    if not obj then return false end
    obj.log.d("> toggleFirst")
    local windows = obj.tilingConfigCurrentSpace().windows
    if #windows > 1 then
        local i = fnutils.indexOf(windows, window.focusedWindow())
        if i then
            if i == 1 then
                obj.moveRelative(1)
            elseif i > 1 then
                table.insert(windows, 1, table.remove(windows, i))
                obj.tileCurrentSpace(windows)
            end
        else
            obj.log.d("Window is floating")
        end
    end
    obj.log.d("< toggleFirst")
end

--- TilingWindowManager.toggleFirstMouseHover() -> nil
--- Function
--- Focuses and raises window under mouse pointer, then calls toogleFirst().
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.toggleFirstMouseHover()
    obj.log.d("> toggleFirstMouseHover")
    local windows = obj.tilingConfigCurrentSpace().windows
    local point = hs.mouse.absolutePosition()
    for i, w in ipairs(windows) do
        if hs.geometry.point(point.x, point.y):inside(w:frame()) then
            w:focus():raise()
        end
    end
    obj.toggleFirst()
    obj.log.d("< toggleFirstMouseHover")
end

-- Menu bar ---------------------------------------------------------

-- Internal: Callback for hs.menubar, is triggered when
-- user selects a layout in menu bar, tiles space and updates menu.
--
-- Parameters:
--  * modifiers - koyboard modifiers
--  * menuItem - table with selected menu item
--
-- Returns:
--  * None
function obj.switchLayout(modifiers, menuItem)
    obj.log.d("> switchLayout",
        inspect(modifiers), inspect(menuItem))
    obj.setLayoutCurrentSpace(menuItem.title)
    obj.tileCurrentSpace()
    obj.updateMenu()
    obj.log.d("< switchLayout")
end

-- Internal: Helper function to convert an ASCII image to an icon.
--
-- Parameters:
--  * None
--
-- Returns:
--  * Icon
---@diagnostic disable-next-line: unused-function
local function iconFromASCII(ascii)
    -- Hacky workaround: make Hammerspoon render the icon by creating
    -- a menubar object, grabbing the icon and deleting the menubar
    -- object.
    local menubar = menubar:new(false):setIcon(ascii)
    local icon = menubar:icon() -- hs.image object
    menubar:delete()
    return icon
end

-- Internal: Generates the menu table for the menu bar.
--
-- Parameters:
--  * None
--
-- Returns:
--  * menu table
function obj.menuTable()
    -- obj.log.d("> menuTable")
    local layoutCurrentSpace = obj.tilingConfigCurrentSpace().layout
    local menuTable = {}

    -- Layouts
    for i, layout in ipairs(obj.enabledLayouts) do
        local menuItem = {}
        menuItem.title = layout
        if not obj.tilingStrategy[layout].icon then
            -- cache icons
            local asciiLayout = obj.tilingStrategy[layout].symbol
            obj.tilingStrategy[layout].icon = obj.menubar:setIcon(asciiLayout):icon()
            -- obj.tilingStrategy[layout].icon = iconFromASCII(asciiLayout)
        end
        menuItem.image = obj.tilingStrategy[layout].icon
        if layout == layoutCurrentSpace then
            menuItem.checked = true
        end
        menuItem.fn = obj.switchLayout
        table.insert(menuTable, menuItem)
    end

    -- Config commands
    table.insert(menuTable, { title = "-" })
    table.insert(menuTable, {
        title = "Main pane +",
        fn = function()
            obj.setMainWindowsRelative(1)
            obj.tileCurrentSpace()
        end
    })
    table.insert(menuTable, {
        title = "Main pane -",
        fn = function()
            obj.setMainWindowsRelative(-1)
            obj.tileCurrentSpace()
        end
    })
    table.insert(menuTable, { title = "-" })
    table.insert(menuTable, {
        title = "Main/Stack +",
        fn = function()
            obj.setMainRatioRelative(0.05)
            obj.tileCurrentSpace()
        end
    })
    table.insert(menuTable, {
        title = "Main/Stack -",
        fn = function()
            obj.setMainRatioRelative(-0.05)
            obj.tileCurrentSpace()
        end
    })
    -- obj.log.d("< menuTable ->", inspect.inspect(menuTable))
    return menuTable
end

-- Internal: Draw the menubar menu.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function obj.updateMenu()
    if not obj.menubar then return end
    obj.log.d("> updateMenu")
    obj.menubar:setIcon(
        obj.tilingStrategy[obj.tilingConfigCurrentSpace().layout].symbol)
    obj.menubar:setMenu(obj.menuTable)
    obj.log.d("< updateMenu")
end

--- TilingWindowManager.displayLayout() -> nil
--- Function
--- Shows an alert displaying the current spaces current layout.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.displayLayout(tilingConfig)
    obj.log.d("> displayLayout")
    local tilingConfig = tilingConfig or obj.tilingConfigCurrentSpace()
    hs.alert(tilingConfig.layout .. " Layout", 1)
    obj.log.d("  Layout:", tilingConfig.layout)
    obj.log.d("  #Main windows:", tilingConfig.mainNumberWindows)
    obj.log.d("  Main ratio:", tilingConfig.mainRatio)
    obj.log.d("< displayLayout")
end

function obj.functionTimer(f)
    obj.log.d("> functionTimer")
    local ttime = os.time()
    local ctime = os.clock()
    f()
    obj.log.d("< functionTimer",
        "time:", os.time() - ttime,
        "clock:", os.clock() - ctime)
end

-- Spoon methods ----------------------------------------------------

--- TilingWindowManager:bindHotkeys(mapping) -> self
--- Method
--- Binds hotkeys for TilingWindowManager
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for
---    the following items
---
--- Notes:
---  * Keys for mapping:
---    - tile - Manually tiles the current macOS space.
---    - focusNext - move focus to next window.
---    - focusPrev - move focus to previous window.
---    - swapNext - swap current window with next window.
---    - swapPrev - swap current window with previous window.
---    - swapFirst - swap current window with first window.
---    - toggleFirst - Toggle current window with first window.
---    - float - switch current space to float layout.
---    - fullscreen - switch current space to fullscreen layout.
---    - tall - switch current space to tall layout.
---    - wide - switch current space to wide layout.
---    - display - display current space layout.
---
--- Returns:
---  * The TilingWindowManager object
function obj:bindHotkeys(mapping)

    obj.log.d("> bindHotkeys", inspect(mapping))
    local def = {
        tile = obj.tileCurrentSpace,
        incMainRatio = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.setMainRatioRelative(0.05)
            obj.tileCurrentSpace()
        end,
        decMainRatio = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.setMainRatioRelative(-0.05)
            obj.tileCurrentSpace()
        end,
        incMainWindows = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.setMainWindowsRelative(1)
            obj.tileCurrentSpace()
        end,
        decMainWindows = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.setMainWindowsRelative(-1)
            obj.tileCurrentSpace()
        end,
        focusNext = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            if obj then obj.focusRelative(1) end
        end,
        focusPrev = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            if obj then obj.focusRelative(-1) end
        end,
        swapNext = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            if obj then obj.moveRelative(1) end
        end,
        swapPrev = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            if obj then obj.moveRelative(-1) end
        end,
        swapFirst = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.swapFirst()
        end,
        toggleFirst = function()
            if settings.get('spaceHammerTWM') == 'stop' then return false end
            obj.toggleFirst()
        end,
        float = function()
            if obj.layouts.float then
                obj.setLayoutCurrentSpace(obj.layouts.float)
            end
        end,
        fullscreen = function()
            if obj.layouts.fullscreen then
                obj.setLayoutCurrentSpace(obj.layouts.fullscreen)
                obj.tileCurrentSpace(true)
            end
        end,
        tall = function()
            if obj.layouts.tall then
                obj.setLayoutCurrentSpace(obj.layouts.tall)
                obj.tileCurrentSpace(true)
            end
        end,
        talltwo = function()
            if obj.layouts.talltwo then
                obj.setLayoutCurrentSpace(obj.layouts.talltwo)
                obj.tileCurrentSpace(true)
            end
        end,
        wide = function()
            if obj.layouts.wide then
                obj.setLayoutCurrentSpace(obj.layouts.wide)
                obj.tileCurrentSpace(true)
            end
        end,
        display = obj.displayLayout,
    }
    spoons.bindHotkeysToSpec(def, mapping)
    obj.log.d("< bindHotkeys")
    return self
end

--- TilingWindowManager:start([config]) -> self
--- Method
--- Starts TilingWindowManager spoon
---
--- Parameters:
---  * config
---    A table with configuration options for the spoon.
---    These keys are recognized:
---   * dynamic - if true: dynamically tile windows.
---   * layouts - a table with all layouts to be enabled.
---   * fullscreenRightApps - a table with app names, to position
---     right half only in fullscreen layout.
---   * floatApp - a table with app names to always float.
---   * displayLayout - if true: show layout when switching tiling layout.
---   * menubar - if true: enable menubar item.
---
--- Returns:
---  * The TilingWindowManager object
function obj:start(config)
    obj.log.d("> start")

    if settings.get('spaceHammerTWM') == 'stop' then
        -- obj.loadTilingConfig()
        obj.layouts = config.layouts
    end

    if config.dynamic == true then
        obj.windowFilter = window.filter.new()
            :setDefaultFilter()
            :setOverrideFilter({
                fullscreen   = false,
                currentSpace = true,
                visible = true,
                hasTitlebar = true,
                allowRoles   = { 'AXStandardWindow' },
            })
            :subscribe({
                window.filter.windowsChanged,
            }, function(_, _, _) obj.tileCurrentSpace(true) end)
    end

    if config.layouts then
        obj.enabledLayouts = config.layouts
    end

    if config.fullscreenRightApps then
        obj.fullscreenRightApps = config.fullscreenRightApps
    end

    if config.floatApps then
        obj.floatApps = config.floatApps
    end

    if config.displayLayout then obj.displayLayoutOnLayoutChange = true end

    if config.menubar == true then
        obj.menubar = menubar.new()
        obj.updateMenu()
    end

    obj.spacesWatcher = hs.spaces.watcher.new(obj.switchedToSpace):start()

    obj.tileCurrentSpace(true)

    obj.log.d("< start")

    return self
end

--- TilingWindowManager:stop() -> self
--- Method
--- Stops TilingWindowManager spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The TilingWindowManager object
function obj:stop()
    obj.log.d("> stop")

    if obj.menubar then obj.menubar:delete() end
    obj.menubar = nil

    if obj.spacesWatcher then obj.spacesWatcher:stop() end
    obj.spacesWatcher = nil

    if obj.windowFilter then obj.windowFilter:unsubscribe(window.filter.windowsChanged) end

    obj.windowFilter = nil
    obj.tileCurrentSpace(false)
    obj.layouts = {}

    obj.log.d("< stop")
    return self
end

function obj:toggleTWM(config)
    if settings.get('spaceHammerTWM') == 'stop' then
        obj:start(config)
        settings.set('spaceHammerTWM', 'start')
    else
        obj:stop()
        settings.set('spaceHammerTWM', 'stop')
    end

end

--- TilingWindowManager:setLogLevel(level) -> self
--- Method
--- Set the log level of the spoon logger.
---
--- Parameters:
---  * Log level
---
--- Returns:
---  * The TilingWindowManager object
function obj:setLogLevel(level)
    obj.log.d("> setLogLevel")
    obj.log.setLogLevel(level)
    obj.log.d("< setLogLevel")
    return self
end

return obj
