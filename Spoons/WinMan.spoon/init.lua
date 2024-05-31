--- === WinMan ===
---
--- Windows manipulation
---
--- Download: [原 WinWin Spoon 地址](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "WinMan"
obj.version = "1.2"
obj.author = "shingo <gmboomker@gmail.com>"
obj.homepage = "https://github.com/boomker/spacehammer"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Windows manipulation history. Only the last operation is stored.
obj.history = {}

--- WinMan.gridparts
--- Variable
--- An integer specifying how many gridparts the screen should be divided into. Defaults to 30.
obj.gridparts = 30

-- Internal method to find out what part of the screen a window gravitates towards (left/right, top/bottom)
--      +------------------+------------------+
--      |   +-------------------+             |   Example: The window gravitates towards left and top
--      |   |              |    |             |
--      |   |              |    |             |
--      +-------------------------------------+
--      |   |              |    |             |
--      |   +-------------------+             |
--      |                  |                  |
--      +------------------+------------------+
-- Perhaps there is a much easier way to calculate this?

function obj:_getWindowGravity(window)
    local screen = window:screen()
    local sFrame = screen:frame()
    local wFrame = window:frame()

    local halfWidth = sFrame.w / 2
    local lMargin = wFrame.x
    local rMargin = sFrame.w - (lMargin + wFrame.w)
    local lPart = halfWidth - lMargin
    local rPart = halfWidth - rMargin

    local halfHeight = sFrame.h / 2
    local tMargin = wFrame.y
    local bMargin = sFrame.h - (tMargin + wFrame.h)
    local tPart = halfHeight - tMargin
    local bPart = halfHeight - bMargin

    return {
        left = lPart >= rPart,
        right = rPart > lPart,
        top = tPart >= bPart,
        bottom = bPart > tPart,
    }
end

--- WinMan:stepMove(direction)
--- Method
--- Move the focused window in the `direction` by on step. The step scale equals to the width/height of one gridpart.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.

function obj:stepMove(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w / obj.gridparts
        local steph = cres.h / obj.gridparts
        local wtopleft = cwin:topLeft()
        if direction == "left" then
            cwin:setTopLeft({ x = wtopleft.x - stepw, y = wtopleft.y })
        elseif direction == "right" then
            cwin:setTopLeft({ x = wtopleft.x + stepw, y = wtopleft.y })
        elseif direction == "up" then
            cwin:setTopLeft({ x = wtopleft.x, y = wtopleft.y - steph })
        elseif direction == "down" then
            cwin:setTopLeft({ x = wtopleft.x, y = wtopleft.y + steph })
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinMan:stepResize(direction)
--- Method
--- Resize the focused window in the `direction` by on step.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.

function obj:stepResize(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local wf = cwin:frame()
        local stepw = cres.w / obj.gridparts
        local steph = cres.h / obj.gridparts
        local wsize = cwin:size()
        if direction == "left" then
            cwin:setSize({ w = wsize.w - stepw, h = wsize.h })
        elseif direction == "right" then
            cwin:setSize({ w = wsize.w + stepw, h = wsize.h })
        elseif direction == "up" then
            cwin:setSize({ w = wsize.w, h = wsize.h - steph })
        elseif direction == "down" then
            cwin:setSize({ w = wsize.w, h = wsize.h + steph })
        elseif direction == "expand" then
            cwin:setSize({ w = wsize.w + stepw, h = wsize.h + steph })
        elseif direction == "shrink" then
            cwin:setSize({ w = wsize.w - stepw, h = wsize.h - steph })
        elseif direction == "rightExpanToScreen" then
            cwin:setSize({ w = cres.w - wf.x, h = wsize.h })
        elseif direction == "leftExpanToScreen" then
            cwin:setFrame({ x = cres.x, y = wf.y, w = wsize.w + wf.x, h = wf.h })
        elseif direction == "upExpanToScreen" then
            cwin:setFrame({ x = wf.x, y = cres.y, w = wf.w, h = wf.h + wf.y })
        elseif direction == "downExpanToScreen" then
            cwin:setSize({ w = wsize.w, h = cres.h })
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinMan:stash()
--- Method
--- Stash current windows's position and size.
---

--- WinMan:smartStepResize(direction)
--- Method
--- Resize the focused window "smartly" by one step. See notes for our definition of smartly.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
---
--- Notes:
--- * If window gravitates to the right, `right` and `left` expands and shrinks the window on the left border.
--- * If window is more to the left, it resizes on the right border.
--- * The same principal applies to `up` and `down`.
--- * When a window is full width or full height, it will shrink/expand in the 'direction' direction.

function obj:smartStepResize(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()

        local cres = cscreen:fullFrame()
        local wf = cwin:frame()
        -- local stepw = cres.w/obj.gridparts
        -- local steph = cres.h/obj.gridparts
        local wsize = cwin:size()
        local gravity = obj:_getWindowGravity(cwin)

        local sFrame = cscreen:frame()
        local wFrame = cwin:frame()
        local isFullWidth = sFrame.w == wFrame.w
        local isFullHeight = sFrame.h == wFrame.h

        if direction == "left" then
            if isFullWidth then
                gravity.left = true
                gravity.right = false
            end
            if gravity.left then
                obj:stepResize("left")
            else
                obj:stepMove("left")
                obj:stepResize("right")
            end
        elseif direction == "right" then
            if isFullWidth then
                gravity.left = false
                gravity.right = true
            end
            if gravity.right then
                obj:stepResize("left")
                obj:stepMove("right")
            else
                obj:stepResize("right")
            end
        elseif direction == "up" then
            if isFullHeight then
                gravity.top = true
                gravity.bottom = false
            end
            if gravity.top then
                obj:stepResize("up")
            else
                obj:stepMove("up")
                obj:stepResize("down")
            end
        elseif direction == "down" then
            if isFullHeight then
                gravity.top = false
                gravity.bottom = true
            end
            if gravity.bottom then
                obj:stepResize("up")
                obj:stepMove("down")
            else
                obj:stepResize("down")
            end
        elseif direction == "rightExpanToScreen" then
            cwin:setSize({ w = cres.w - wf.x, h = wsize.h })
        elseif direction == "leftExpanToScreen" then
            cwin:setFrame({ x = cres.x, y = wf.y, w = wsize.w + wf.x, h = wf.h })
        elseif direction == "upExpanToScreen" then
            cwin:setFrame({ x = wf.x, y = cres.y, w = wf.w, h = wf.h + wf.y })
        elseif direction == "downExpanToScreen" then
            cwin:setSize({ w = wsize.w, h = cres.h })
        else
            hs.alert.show("Unknown direction: " .. direction)
        end
    else
        hs.alert.show("No focused window!")
    end
end

local function isInHistory(windowid)
    for idx, val in ipairs(obj.history) do
        if val[1] == windowid then
            return idx
        end
    end
    return false
end

function obj:stash()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    local winf = cwin:frame()
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            -- Make sure the history for each application doesn't reach the maximum (100 items)
            local id_history = obj.history[1][2]
            if #id_history > 100 then
                table.remove(id_history)
            end
            table.insert(id_history, 1, winf)
        else
            local id_history = obj.history[id_idx][2]
            if #id_history > 100 then
                table.remove(id_history)
            end
            table.insert(id_history, 1, winf)
        end
    else
        -- Make sure the history of window id doesn't reach the maximum (100 items).
        if #obj.history > 100 then
            table.remove(obj.history)
        end
        -- Stash new window id and its first history
        local newtable = { winid, { winf } }
        table.insert(obj.history, 1, newtable)
    end
end

--- WinMan:moveAndResize(option)
--- Method
--- Move and resize the focused window.
---
--- Parameters:
---  * option - A string specifying the option, valid strings are: `halfleft`, `halfright`, `halfup`, `halfdown`,
--    `cornerNW`, `cornerSW`, `cornerNE`, `cornerSE`, `center`, `fullscreen`, `expand`, `shrink`.
-- 增加 mostleft、mostright、lesshalfleft、onethird、lesshalfright

function obj:moveAndResize(option)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        -- local stepw = cres.w/obj.gridparts
        -- local steph = cres.h/obj.gridparts
        local wf = cwin:frame()
        local options = {
            halfleft = function()
                cwin:setFrame({ x = cres.x, y = cres.y, w = cres.w / 2, h = cres.h })
            end,
            halfright = function()
                cwin:setFrame({ x = cres.x + cres.w / 2, y = cres.y, w = cres.w / 2, h = cres.h })
            end,
            halfup = function()
                cwin:setFrame({ x = cres.x, y = cres.y, w = cres.w, h = cres.h / 2 })
            end,
            halfdown = function()
                cwin:setFrame({ x = cres.x, y = cres.y + cres.h / 2, w = cres.w, h = cres.h / 2 })
            end,
            cornerNW = function()
                cwin:setFrame({ x = cres.x, y = cres.y, w = cres.w / 2, h = cres.h / 2 })
            end,
            cornerNE = function()
                cwin:setFrame({ x = cres.x + cres.w / 2, y = cres.y, w = cres.w / 2, h = cres.h / 2 })
            end,
            cornerSW = function()
                cwin:setFrame({ x = cres.x, y = cres.y + cres.h / 2, w = cres.w / 2, h = cres.h / 2 })
            end,
            cornerSE = function()
                cwin:setFrame({ x = cres.x + cres.w / 2, y = cres.y + cres.h / 2, w = cres.w / 2, h = cres.h / 2 })
            end,
            fullscreen = function()
                cwin:toggleFullScreen()
            end,
            maximize = function()
                cwin:maximize()
            end,
            minimize = function()
                cwin:minimize()
            end,
            center = function()
                cwin:centerOnScreen()
            end,
            screenRB = function()
                cwin:setFrame({ x = cres.w - wf.w, y = wf.y, w = wf.w, h = wf.h })
            end,
            screenLB = function()
                cwin:setFrame({ x = cres.x, y = wf.y, w = wf.w, h = wf.h })
            end,
            screenUB = function()
                cwin:setFrame({ x = wf.x, y = cres.y, w = wf.w, h = wf.h })
            end,
            screenDB = function()
                cwin:setFrame({ x = wf.x, y = cres.h - wf.h, w = wf.w, h = wf.h })
            end,
            screenCornerNW = function()
                cwin:setFrame({ x = cres.x, y = cres.y, w = wf.w, h = wf.h })
            end,
            screenCornerNE = function()
                cwin:setFrame({ x = cres.w - wf.w, y = cres.y, w = wf.w, h = wf.h })
            end,
            screenCornerSW = function()
                cwin:setFrame({ x = cres.x, y = cres.y + (cres.h - wf.h), w = wf.w, h = wf.h })
            end,
            screenCornerSE = function()
                cwin:setFrame({ x = cres.x + (cres.w - wf.w), y = cres.y + (cres.h - wf.h), w = wf.w, h = wf.h })
            end,
            expand = function()
                obj:stepResize("expand")
            end,
            shrink = function()
                obj:stepResize("shrink")
            end,
        }

        if options[option] then
            -- obj:stash()
            return options[option]()
        else
            hs.alert.show("Unknown option: " .. option)
        end
        -- if option == "halfleft" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
        -- elseif option == "halfright" then
        --     cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
        -- -- 定义  lesshalfleft、onethird、lesshalfright
        -- elseif option == "lesshalfleft" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/3, h=cres.h})
        -- elseif option == "onethird" then
        --     cwin:setFrame({x=cres.x+cres.w/3, y=cres.y, w=cres.w/3, h=cres.h})
        -- elseif option == "lesshalfright" then
        --     cwin:setFrame({x=cres.x+cres.w/3*2, y=cres.y, w=cres.w/3, h=cres.h})

        -- -- 定义 mostleft、mostright
        -- elseif option == "mostleft" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/3*2, h=cres.h})
        -- elseif option == "mostright" then
        --     cwin:setFrame({x=cres.x+cres.w/3, y=cres.y, w=cres.w/3*2, h=cres.h})

        -- -- 定义 centermost
        -- elseif option == "centermost" then
        --     -- cwin:setFrame({x=cres.x+cres.w/3/2, y=cres.h/96, w=cres.w/3*2, h=cres.h})
        --     cwin:setFrame({x=cres.x+cres.w/3/2, y=cres.y, w=cres.w/3*2, h=cres.h})

        -- -- 定义 show
        -- -- 宽度为24 分之 22
        -- elseif option == "show" then
        --     -- cwin:setFrame({x=cres.x+cres.w/3/2/2/2/2, y=cres.h/96, w=cres.w/48*46, h=cres.h})
        --     cwin:setFrame({x=cres.x+cres.w/3/2/2/2/2, y=cres.y, w=cres.w/48*46, h=cres.h})

        -- -- 定义 shows
        -- elseif option == "shows" then
        --     -- cwin:setFrame({x=cres.x+cres.w/3/2/2, y=cres.h/96, w=cres.w/12*10, h=cres.h})
        --     cwin:setFrame({x=cres.x+cres.w/3/2/2, y=cres.y, w=cres.w/12*10, h=cres.h})

        -- -- 定义 center-2
        -- elseif option == "center-2" then
        --     cwin:setFrame({x=cres.x+cres.w/2/2, y=cres.y, w=cres.w/2, h=cres.h})

        -- elseif option == "halfup" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
        -- elseif option == "halfdown" then
        --     cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
        -- elseif option == "cornerNW" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2})
        -- elseif option == "cornerNE" then
        --     cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2})
        -- elseif option == "cornerSW" then
        --     cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        -- elseif option == "cornerSE" then
        --     cwin:setFrame({x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        -- elseif option == "fullscreen" then
        --     -- cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
        --     cwin:toggleFullScreen()
        -- elseif option == "max" then
        --     cwin:maximize()
        -- elseif option == "center" then
        --     cwin:centerOnScreen()
        -- elseif option == "screenRB" then
        --     cwin:setFrame({x=cres.w-wf.w, y=wf.y, w=wf.w, h=wf.h})
        -- elseif option == "screenLB" then
        --     cwin:setFrame({x=cres.x, y=wf.y, w=wf.w, h=wf.h})
        -- elseif option == "screenDB" then
        --     cwin:setFrame({x=wf.x, y=cres.h-wf.h, w=wf.w, h=wf.h})
        -- elseif option == "screenUB" then
        --     cwin:setFrame({x=wf.x, y=cres.y, w=wf.w, h=wf.h})

        -- elseif option == "screenCornerNW" then
        --     cwin:setFrame({x=cres.x, y=cres.y, w=wf.w, h=wf.h})
        -- elseif option == "screenCornerNE" then
        --     cwin:setFrame({x=cres.w-wf.w, y=cres.y, w=wf.w, h=wf.h})
        -- elseif option == "screenCornerSW" then
        --     cwin:setFrame({x=cres.x, y=cres.y+(cres.h-wf.h), w=wf.w, h=wf.h})
        -- elseif option == "screenCornerSE" then
        cwin:setFrame({ x = cres.x + (cres.w - wf.w), y = cres.y + (cres.h - wf.h), w = wf.w, h = wf.h })
        -- elseif option == "expand" then
        --     -- cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)})
        --     obj:stepResize("expand")
        -- elseif option == "shrink" then
        obj:stepResize("shrink")
        -- cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)})
        -- end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinMan:cMoveToScreen(direction)
--- Method
--- Move the focused window between all of the screens in the `direction`.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`, `next`.

function obj:cMoveToScreen(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        if direction == "up" then
            cwin:moveOneScreenNorth()
        elseif direction == "down" then
            cwin:moveOneScreenSouth()
        elseif direction == "left" then
            cwin:moveOneScreenWest()
        elseif direction == "right" then
            cwin:moveOneScreenEast()
        elseif direction == "next" then
            cwin:cMoveToScreen(cscreen:next())
        end
    else
        hs.alert.show("No focused window!")
    end
end

local function getTargetSpaceID(direction)
    local curSpaceID = hs.spaces.focusedSpace()
    local curScreenAllSpaceIDs = hs.spaces.spacesForScreen()
    table.sort(curScreenAllSpaceIDs)
    local nextSpaceIndex = hs.fnutils.indexOf(curScreenAllSpaceIDs, curSpaceID)
    if nextSpaceIndex == #curScreenAllSpaceIDs then
        if direction == "next" then
            nextSpaceIndex = 1
        else
            nextSpaceIndex = nextSpaceIndex - 1
        end
    else
        if direction == "next" then
            nextSpaceIndex = nextSpaceIndex + 1
        else
            nextSpaceIndex = nextSpaceIndex - 1
            -- if nextSpaceIndex == 0 then
            --     nextSpaceIndex = #curScreenAllSpaceIDs
            -- end
        end
    end
    return curScreenAllSpaceIDs[nextSpaceIndex], nextSpaceIndex
end

local PaperWM = hs.loadSpoon("PaperWM")

function obj:moveToSpace(direction, followWindow)
    local windowObj = hs.window.focusedWindow()
    local mousePosition = hs.mouse.absolutePosition()
    if not windowObj then
        hs.alert.show("No focused window!")
    end
    if direction == "right" then
        local nextSpaceID, nextSpaceIndex = getTargetSpaceID("next")

        -- hs.spaces.moveWindowToSpace(windowObj, nextSpaceID)
        PaperWM:moveWindowToSpace(nextSpaceIndex, windowObj)
    elseif direction == "left" then
        local prevSpaceID, prevSpaceIndex = getTargetSpaceID("prev")
        -- hs.spaces.moveWindowToSpace(windowObj, prevSpaceID)
        PaperWM:moveWindowToSpace(prevSpaceIndex, windowObj)
    end
    -- 跟随窗口一起移动到下一个 space
    if followWindow then
        local newWindowObj = hs.window.frontmostWindow()
        newWindowObj:focus()
    else
        hs.eventtap.leftClick(mousePosition)
    end
end

--[[
function obj:jumpToWindowAndFocus()
    local windowObj = hs.window.focusedWindow()
    local curWindowID = nil
    if windowObj then
        curWindowID = windowObj:id()
    else
        hs.alert.show("当前没有聚焦到任何窗口", 0.5)
        return false
    end

    local window_filter = hs.window.filter.new():setOverrideFilter({
        visible = true,
        fullscreen = false,
        hasTitlebar = true,
        currentSpace = true,
        allowRoles = "AXStandardWindow",
    })

    local _curSpaceAllWindows = window_filter:getWindows()

    local curSpaceAllWindowsID = {}
    for _, window in ipairs(_curSpaceAllWindows) do
        if window ~= nil and window:isStandard() and not window:isMinimized() then
            table.insert(curSpaceAllWindowsID, window:id())
        end
    end

    table.sort(curSpaceAllWindowsID)
    local curWinIDIndex = hs.fnutils.indexOf(curSpaceAllWindowsID, curWindowID)
    if not curWinIDIndex then
        return false
    end
    local nextFocusedWindowIndex = nil
    if curWinIDIndex == #curSpaceAllWindowsID then
        nextFocusedWindowIndex = 1
    else
        nextFocusedWindowIndex = curWinIDIndex + 1
    end

    local nextFocusedWindowID = curSpaceAllWindowsID[nextFocusedWindowIndex]

    local nextFocusWindow = hs.window.get(nextFocusedWindowID)
    if nextFocusWindow then
        nextFocusWindow:focus()
    else
        hs.alert.show("No focused window!")
        return false
    end
end
--]]

--- WinMan:undo()
--- Method
--- Undo the last window manipulation. Only those "moveAndResize" manipulations can be undone.
---

function obj:undo()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    -- Has this window been stored previously?
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            local id_history = obj.history[1][2]
            cwin:setFrame(id_history[1])
            -- Rewind the history
            local tmpframe = id_history[1]
            table.remove(id_history, 1)
            table.insert(id_history, tmpframe)
        else
            local id_history = obj.history[id_idx][2]
            cwin:setFrame(id_history[1])
            local tmpframe = id_history[1]
            table.remove(id_history, 1)
            table.insert(id_history, tmpframe)
        end
    end
end

--- WinMan:redo()
--- Method
--- Redo the window manipulation. Only those "moveAndResize" manipulations can be undone.
---

function obj:redo()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    -- Has this window been stored previously?
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            local id_history = obj.history[1][2]
            cwin:setFrame(id_history[#id_history])
            -- Play the history
            local tmpframe = id_history[#id_history]
            table.remove(id_history)
            table.insert(id_history, 1, tmpframe)
        else
            local id_history = obj.history[id_idx][2]
            cwin:setFrame(id_history[#id_history])
            local tmpframe = id_history[#id_history]
            table.remove(id_history)
            table.insert(id_history, 1, tmpframe)
        end
    end
end

--- WinMan:centerCursor()
--- Method
--- Center the cursor on the focused window.
---

function obj:centerCursor()
    local cwin = hs.window.focusedWindow()
    local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:fullFrame()
    if cwin then
        -- Center the cursor one the focused window
        hs.mouse.setAbsolutePosition({ x = wf.x + wf.w / 2, y = wf.y + wf.h / 2 })
    else
        -- Center the cursor on the screen
        hs.mouse.setAbsolutePosition({ x = cres.x + cres.w / 2, y = cres.y + cres.h / 2 })
    end
end

return obj
