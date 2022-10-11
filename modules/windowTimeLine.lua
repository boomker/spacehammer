---@diagnostic disable: lowercase-global

WTL = {
    undoStack = {},
    redoStack = {},
    stackMax = 30,
    skip = false,
}


local function compareFrame(t1, t2)
    if t1 == t2 then return true end
    if t1 and t2 then
        return t1.x == t2.x and t1.y == t2.y and t1.w == t2.w and t1.h == t2.h
    end
    return false
end

function WTL:addToStack(type, wins)
    if self.skip then return end
    if not wins then wins = { hs.window.focusedWindow() } end
    if type == "undo" then
        local size = #self.undoStack
        self.undoStack[size + 1] = self:getCurrentWindowsLayout(wins)
        local stackSize = #self.undoStack
        if stackSize > self.stackMax then
            for i = 1, stackSize - self.stackMax do
                self.undoStack[1] = nil
            end
        end
    else
        local size = #self.redoStack
        self.redoStack[size + 1] = self:getCurrentWindowsLayout(wins)
        local stackSize = #self.redoStack
        if stackSize > self.stackMax then
            for i = 1, stackSize - self.stackMax do
                self.redoStack[1] = nil
            end
        end
    end
end

function WTL:undo()
    local size = #self.undoStack
    if size > 0 then
        local status = self.undoStack[size]
        for w, f in pairs(status) do
            if w and f and w:isVisible() and w:isStandard() and w:id() then
                if not compareFrame(f, w:frame()) then
                    w:setFrame(f)
                end
            end
        end
        self.undoStack[size] = nil
    else
        hs.alert('Reach Undo End', 0.5)
    end
end

function WTL:redo()
    local size = #self.redoStack
    if size > 0 then
        local status = self.redoStack[size]
        for w, f in pairs(status) do
            if w and f and w:isVisible() and w:isStandard() and w:id() then
                if not compareFrame(f, w:frame()) then
                    w:setFrame(f)
                end
            end
        end
        self.redoStack[size] = nil
    else
        hs.alert('Reach Redo End', 0.5)
    end
end

function WTL:getCurrentWindowsLayout(wins)
    if not wins then wins = { hs.window.focusedWindow() } end
    local current = {}
    for i = 1, #wins do
        local w = wins[i]
        local f = w:frame()
        if w:isVisible() and w:isStandard() and w:id() and f then
            current[w] = f
        end
    end
    return current
end

return WTL
