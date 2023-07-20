# TaskHelper.spoon

A spoon (plugin) for [hammerspoon](https://www.hammerspoon.org) that provides a wrapper around hs.task that shows notifications and logs stdout/stderr.

## Setup

Clone this repository inside of `~/.hammerspoon/Spoons`, then add `hs.loadSpoon("TaskHelper")` to your `init.lua`.

## Usage

|Function name|Description|
|---|---|
|run(title, path\[, arguments\[, options\]\])|Starts the program at the given path, with the given list of arguments. Shows a failure notification based if the exit code is nonzero, using the given title. Logs exit code, stdout, and stderr to the Hammerspoon console. Set `options.notifyOnSuccess` to `true` if you want a temporary notification to be shown on successes too.|

## License

This is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
