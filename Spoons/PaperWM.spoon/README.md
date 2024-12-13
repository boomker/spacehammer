# PaperWM.spoon

Tiled scrollable window manager for MacOS. Inspired by
[PaperWM](https://github.com/paperwm/PaperWM).

Spoon plugin for [HammerSpoon](https://www.hammerspoon.org) MacOS automation app.

# Demo

https://user-images.githubusercontent.com/900731/147793584-f937811a-20aa-4282-baf5-035e5ddc12ea.mp4

## Installation

1. Clone to Hammerspoon Spoons directory: `git clone https://github.com/mogenson/PaperWM.spoon ~/.hammerspoon/Spoons/PaperWM.spoon`.

2. Open `System Preferences` -> `Mission Control`. Uncheck "Automatically
rearrange Spaces based on most recent use" and check "Displays have separate
Spaces".

<img width="780" alt="Screen Shot 2022-01-07 at 14 10 11" src="https://user-images.githubusercontent.com/900731/148595715-1f7a3509-1289-4d10-b64d-86b84c076b43.png">

### Install with [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html)

```lua
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.PaperWM = {
    url = "https://github.com/mogenson/PaperWM.spoon",
    desc = "PaperWM.spoon repository",
    branch = "release",
}

spoon.SpoonInstall:andUse("PaperWM", {
    repo = "PaperWM",
    config = { screen_margin = 16, window_gap = 2 },
    start = true,
    hotkeys = {
		< see below >
    }
})
```

## Usage

Add the following to your `~/.hammerspoon/init.lua`:

```lua
PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
    -- switch to a new focused window in tiled grid
    focus_left  = {{"alt", "cmd"}, "left"},
    focus_right = {{"alt", "cmd"}, "right"},
    focus_up    = {{"alt", "cmd"}, "up"},
    focus_down  = {{"alt", "cmd"}, "down"},

    -- move windows around in tiled grid
    swap_left  = {{"alt", "cmd", "shift"}, "left"},
    swap_right = {{"alt", "cmd", "shift"}, "right"},
    swap_up    = {{"alt", "cmd", "shift"}, "up"},
    swap_down  = {{"alt", "cmd", "shift"}, "down"},

    -- position and resize focused window
    center_window        = {{"alt", "cmd"}, "c"},
    full_width           = {{"alt", "cmd"}, "f"},
    cycle_width          = {{"alt", "cmd"}, "r"},
    reverse_cycle_width  = {{"ctrl", "alt", "cmd"}, "r"},
    cycle_height         = {{"alt", "cmd", "shift"}, "r"},
    reverse_cycle_height = {{"ctrl", "alt", "cmd", "shift"}, "r"},

    -- move focused window into / out of a column
    slurp_in = {{"alt", "cmd"}, "i"},
    barf_out = {{"alt", "cmd"}, "o"},

    -- move the focused window into / out of the tiling layer
    toggle_floating = {{"alt", "cmd", "shift"}, "escape"},

    -- switch to a new Mission Control space
    switch_space_l = {{"alt", "cmd"}, ","},
    switch_space_r = {{"alt", "cmd"}, "."},
    switch_space_1 = {{"alt", "cmd"}, "1"},
    switch_space_2 = {{"alt", "cmd"}, "2"},
    switch_space_3 = {{"alt", "cmd"}, "3"},
    switch_space_4 = {{"alt", "cmd"}, "4"},
    switch_space_5 = {{"alt", "cmd"}, "5"},
    switch_space_6 = {{"alt", "cmd"}, "6"},
    switch_space_7 = {{"alt", "cmd"}, "7"},
    switch_space_8 = {{"alt", "cmd"}, "8"},
    switch_space_9 = {{"alt", "cmd"}, "9"},

    -- move focused window to a new space and tile
    move_window_1 = {{"alt", "cmd", "shift"}, "1"},
    move_window_2 = {{"alt", "cmd", "shift"}, "2"},
    move_window_3 = {{"alt", "cmd", "shift"}, "3"},
    move_window_4 = {{"alt", "cmd", "shift"}, "4"},
    move_window_5 = {{"alt", "cmd", "shift"}, "5"},
    move_window_6 = {{"alt", "cmd", "shift"}, "6"},
    move_window_7 = {{"alt", "cmd", "shift"}, "7"},
    move_window_8 = {{"alt", "cmd", "shift"}, "8"},
    move_window_9 = {{"alt", "cmd", "shift"}, "9"}
})
PaperWM:start()
```

Feel free to customize hotkeys or use
`PaperWM:bindHotkeys(PaperWM.default_hotkeys)` for defaults. PaperWM actions are also
available for manual keybinding via the `PaperWM.actions` table; for example, the
following would enable navigation by either arrow keys or vim-style h/j/k/l directions:

```lua
PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys(PaperWM.default_hotkeys)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "h", PaperWM.actions.focus_left)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "j", PaperWM.actions.focus_down)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "k", PaperWM.actions.focus_up)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "l", PaperWM.actions.focus_right)

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "h", PaperWM.actions.swap_left)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "j", PaperWM.actions.swap_down)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "k", PaperWM.actions.swap_up)
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "l", PaperWM.actions.swap_right)
```

`PaperWM:start()` will begin automatically tiling new and existing windows. `PaperWM:stop()` will
release control over windows.

Set `PaperWM.window_gap` to the number of pixels to space between windows and
the top and bottom screen edges.

Configure one or many `PaperWM.window_filter:rejectApp("appName")` to ignore specific applications. For example:

```lua
PaperWM.window_filter:rejectApp("iStat Menus Status")
PaperWM.window_filter:rejectApp("Finder")
PaperWM:start() -- restart for new window filter to take effect
```

Set `PaperWM.window_ratios` to the ratios to cycle window widths and heights
through. For example:

```lua
PaperWM.window_ratios = { 0.23607, 0.38195, 0.61804 }
```

## Limitations

MacOS does not allow a window to be moved fully off-screen. Windows that would
be tiled off-screen are placed in a margin on the left and right edge of the
screen. They are still visible and clickable.

It's difficult to detect when a window is dragged from one space or screen to
another. Use the `move_window_N` commands to move windows between spaces and
screens.

Arrange screens vertically to prevent windows from bleeding into other screens.

<img width="780" alt="Screen Shot 2022-01-07 at 14 18 27" src="https://user-images.githubusercontent.com/900731/148595785-546f9086-9add-4731-8477-233b202378f4.png">

## Add-ons

The following Spoons compliment PaperWM.spoon nicely.

- [ActiveSpace.spoon](https://github.com/mogenson/ActiveSpace.Spoon) Show active and layout of Mission Control spaces in the menu bar.
- [Swipe.spoon](https://github.com/mogenson/Swipe.spoon) Perform actions when trackpad swipe gestures are recognized. Here's an example config to change PaperWM.spoon focused window:
```lua
-- focus adjacent window with 3 finger swipe
local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
Swipe:start(3, function(direction, distance, id)
    if id == current_id then
        if distance > threshold then
            threshold = math.huge -- trigger once per swipe

            -- use "natural" scrolling
            if direction == "left" then
                PaperWM.actions.focus_right()
            elseif direction == "right" then
                PaperWM.actions.focus_left()
            elseif direction == "up" then
                PaperWM.actions.focus_down()
            elseif direction == "down" then
                PaperWM.actions.focus_up()
            end
        end
    else
        current_id = id
        threshold = 0.2 -- swipe distance > 20% of trackpad size
    end
end)
```

## Contributing

Contributions are welcome! Here are a few preferences:
- Global variables are `CamelCase` (eg. `PaperWM`)
- Local variables are `snake_case` (eg. `local focused_window`)
- Function names are `lowerCamelCase` (eg. `function windowEventHandler()`)
- Use `<const>` where possible
- Create a local copy when deeply nested members are used often (eg. `local Watcher <const> = hs.uielement.watcher`)

Code format checking and linting is provided by [lua-language-server](https://github.com/LuaLS/lua-language-server) for commits and pull requests. Run `lua-language-server --check=init.lua` locally before commiting.
