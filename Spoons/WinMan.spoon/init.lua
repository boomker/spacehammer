--- === WinMan ===
---
--- Windows manipulation
---
--- Download: [原 WinWin Spoon 地址](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "WinMan"
obj.version = "1.1"
obj.author = "shingo <gmboomker@gmail.com>"
obj.homepage = "https://github.com/boomker/spacehammer"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Windows manipulation history. Only the last operation is stored.
obj.history = {}

obj.alreadyFocusedWindowsID = {}

--- WinMan.gridparts
--- Variable
--- An integer specifying how many gridparts the screen should be divided into. Defaults to 30.
obj.gridparts = 30

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
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wtopleft = cwin:topLeft()
        if direction == "left" then
            cwin:setTopLeft({x=wtopleft.x-stepw, y=wtopleft.y})
        elseif direction == "right" then
            cwin:setTopLeft({x=wtopleft.x+stepw, y=wtopleft.y})
        elseif direction == "up" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y-steph})
        elseif direction == "down" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y+steph})
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
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wsize = cwin:size()
        if direction == "left" then
            cwin:setSize({w=wsize.w-stepw, h=wsize.h})
        elseif direction == "right" then
            cwin:setSize({w=wsize.w+stepw, h=wsize.h})
        elseif direction == "up" then
            cwin:setSize({w=wsize.w, h=wsize.h-steph})
        elseif direction == "down" then
            cwin:setSize({w=wsize.w, h=wsize.h+steph})
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinMan:stash()
--- Method
--- Stash current windows's position and size.
---

local function isInHistory(windowid)
    for idx,val in ipairs(obj.history) do
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
            if #id_history > 100 then table.remove(id_history) end
            table.insert(id_history, 1, winf)
        else
            local id_history = obj.history[id_idx][2]
            if #id_history > 100 then table.remove(id_history) end
            table.insert(id_history, 1, winf)
        end
    else
        -- Make sure the history of window id doesn't reach the maximum (100 items).
        if #obj.history > 100 then table.remove(obj.history) end
        -- Stash new window id and its first history
        local newtable = {winid, {winf}}
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
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wf = cwin:frame()
        if option == "halfleft" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
        elseif option == "halfright" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
        -- 定义  lesshalfleft、onethird、lesshalfright
        elseif option == "lesshalfleft" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/3, h=cres.h})
        elseif option == "onethird" then
            cwin:setFrame({x=cres.x+cres.w/3, y=cres.y, w=cres.w/3, h=cres.h})
        elseif option == "lesshalfright" then
            cwin:setFrame({x=cres.x+cres.w/3*2, y=cres.y, w=cres.w/3, h=cres.h})
        
        -- 定义 mostleft、mostright
        elseif option == "mostleft" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/3*2, h=cres.h})
        elseif option == "mostright" then
            cwin:setFrame({x=cres.x+cres.w/3, y=cres.y, w=cres.w/3*2, h=cres.h})
        
        -- 定义 centermost
        elseif option == "centermost" then
            -- cwin:setFrame({x=cres.x+cres.w/3/2, y=cres.h/96, w=cres.w/3*2, h=cres.h})
            cwin:setFrame({x=cres.x+cres.w/3/2, y=cres.y, w=cres.w/3*2, h=cres.h})
            
        -- 定义 show 
        -- 宽度为24 分之 22
        elseif option == "show" then
            -- cwin:setFrame({x=cres.x+cres.w/3/2/2/2/2, y=cres.h/96, w=cres.w/48*46, h=cres.h})
            cwin:setFrame({x=cres.x+cres.w/3/2/2/2/2, y=cres.y, w=cres.w/48*46, h=cres.h})
        
        -- 定义 shows
        elseif option == "shows" then
            -- cwin:setFrame({x=cres.x+cres.w/3/2/2, y=cres.h/96, w=cres.w/12*10, h=cres.h})
            cwin:setFrame({x=cres.x+cres.w/3/2/2, y=cres.y, w=cres.w/12*10, h=cres.h})
         
        -- 定义 center-2 
        elseif option == "center-2" then
            cwin:setFrame({x=cres.x+cres.w/2/2, y=cres.y, w=cres.w/2, h=cres.h})
             
        elseif option == "halfup" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
        elseif option == "halfdown" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
        elseif option == "cornerNW" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerNE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSW" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "fullscreen" then
            -- cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
            cwin:toggleFullScreen()
        elseif option == "max" then
            cwin:maximize()
        elseif option == "center" then
            cwin:centerOnScreen()
        elseif option == "screenRB" then
            cwin:setFrame({x=cres.w-wf.w, y=wf.y, w=wf.w, h=wf.h})
        elseif option == "screenLB" then
            cwin:setFrame({x=cres.x, y=cres.y, w=wf.w, h=wf.h})
            cwin:setFrame({x=cres.x, y=wf.y, w=wf.w, h=wf.h})
        elseif option == "screenDB" then
            cwin:setFrame({x=wf.x, y=cres.y+(cres.h-wf.h), w=wf.w, h=wf.h})
        elseif option == "screenUB" then
            cwin:setFrame({x=wf.x, y=cres.y, w=wf.w, h=wf.h})

        elseif option == "screenCornerNW" then
            cwin:setFrame({x=cres.x, y=cres.y, w=wf.w, h=wf.h})
        elseif option == "screenCornerNE" then
            cwin:setFrame({x=cres.w-wf.w, y=cres.y, w=wf.w, h=wf.h})
        elseif option == "screenCornerSW" then
            cwin:setFrame({x=cres.x, y=cres.y+(cres.h-wf.h), w=wf.w, h=wf.h})
        elseif option == "screenCornerSE" then
            cwin:setFrame({x=cres.x+(cres.w-wf.w), y=cres.y+(cres.h-wf.h), w=wf.w, h=wf.h})
        elseif option == "expand" then
            cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)})
        elseif option == "shrink" then
            cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)})
        end
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

local function getNextSID(direction)
    local curSpaceID = hs.spaces.focusedSpace()
    local curScreenAllSpaceIDs = hs.spaces.spacesForScreen()
    local nextSpaceID = 0
    if direction == "right" then
        for _, v in ipairs(curScreenAllSpaceIDs) do
            if curSpaceID < v then
                nextSpaceID = v
                break
            end
        end
        if nextSpaceID == 0 then
            nextSpaceID = 1
        end
    else
        for i, v in ipairs(curScreenAllSpaceIDs) do
            if curSpaceID == v then
                local nextSpaceIndex = i - 1
                if nextSpaceIndex == 0 then
                    nextSpaceID = curScreenAllSpaceIDs[#curScreenAllSpaceIDs]
                else
                    nextSpaceID = curScreenAllSpaceIDs[nextSpaceIndex]
                end
            end
        end
    end
    return nextSpaceID
end

function obj:moveToSpace(direction)
    local windowObj = hs.window.focusedWindow()
    if windowObj then
        if direction == "right" then
            local nextSpaceID = getNextSID("right")
            hs.spaces.moveWindowToSpace(windowObj, nextSpaceID)
        elseif direction == "left" then
            local nextSpaceID = getNextSID("left")
            hs.spaces.moveWindowToSpace(windowObj, nextSpaceID)
        end
    else
        hs.alert.show("No focused window!")
    end
end

-- function obj:moveAndFocusToSpace(direction)
--     local windowObj = hs.window.focusedWindow()
--     self:moveToSpace(direction)
--     local nsid = getNextSID(direction)
--     print(nsid)
--     hs.spaces.gotoSpace(nsid)
--     windowObj:focus()
-- end


function obj:jumpToWindowAndFocus()
    local windowObj = hs.window.focusedWindow()
    local curWindowID = nil
    if windowObj then
        curWindowID = windowObj:id()
    else
        hs.alert.show("当前没有聚焦到任何窗口", 0.5)
        return false
    end

    local nextFocusedWindowID = nil
    table.insert(obj.alreadyFocusedWindowsID, curWindowID)

    local window_filter = hs.window.filter.new():setOverrideFilter({
        visible = true,
        fullscreen = false,
        hasTitlebar = true,
        currentSpace=true,
        allowRoles = "AXStandardWindow"
    })

    local _curSpaceAllWindows = window_filter:getWindows()

    local curSpaceAllWindowsID = {}
    for _, window in ipairs(_curSpaceAllWindows) do
        if window ~= nil and window:isStandard() and not window:isMinimized() then
            table.insert(curSpaceAllWindowsID, window:id())
        end
    end

    if #obj.alreadyFocusedWindowsID == #curSpaceAllWindowsID then
        nextFocusedWindowID = obj.alreadyFocusedWindowsID[1]
        local nextFocusWindow = hs.window.get(nextFocusedWindowID)
        nextFocusWindow:focus()
        obj.alreadyFocusedWindowsID = {}
        return
    end

    for _, awindowID in ipairs(obj.alreadyFocusedWindowsID) do
        for i, cwindowID in ipairs(curSpaceAllWindowsID) do
            if cwindowID == awindowID then
                table.remove(curSpaceAllWindowsID, i)
                break
            end
        end
    end
    -- print(hs.inspect(curSpaceAllWindowsID))
    if #curSpaceAllWindowsID ~= 0 then
        nextFocusedWindowID = curSpaceAllWindowsID[1]
    else
        nextFocusedWindowID = obj.alreadyFocusedWindowsID[2]
    end
    local nextFocusWindow = hs.window.get(nextFocusedWindowID)
    if nextFocusWindow then
        nextFocusWindow:focus()
    else
        hs.alert.show("No focused window!")
        return false
    end

end

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
        hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
    else
        -- Center the cursor on the screen
        hs.mouse.setAbsolutePosition({x=cres.x+cres.w/2, y=cres.y+cres.h/2})
    end
end

return obj