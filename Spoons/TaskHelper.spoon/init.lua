local obj = {}
obj.__index = obj

-- Metadata
obj.name = "TaskHelper"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- TaskHelper.logger
--- Variable
--- An instance of hs.logger
obj.logger = hs.logger.new('TaskHelper', 'info')

--- TaskHelper.run(title, path[, arguments[, options]])
--- Function
--- Runs the executable at the given path, with the given table of arguments.
--- If the exit code is nonzero, a failure notification will be shown.
--- Stdout and stderr are output with TaskHelper.logger at info and warning level respectively
--- Options:
---   notifyOnSuccess: if true, show a temporary success notification when the command completes successfully
function obj.run(title, path, arguments, options)
    options = options or {}
    local function taskCallback(exitCode, stdOut, stdErr)
        local logTitle = title .. " " .. path .. " " .. hs.inspect.inspect(arguments)
        local exitMsg = "returned " .. exitCode
        local logExitMsg = logTitle .. " " .. exitMsg
        local notifMsg = path .. " " .. exitMsg
        if exitCode == 0 then
            obj.logger.i(logExitMsg)
            if options.notifyOnSuccess then
                hs.notify.show(title, 'Succeeded', notifMsg)
            end
        else
            obj.logger.w(logExitMsg)
            hs.notify.new({
                title = title,
                subTitle = "Failed",
                informativeText = notifMsg,
                autoWithdraw = false,
                withdrawAfter = 0
            }):send()
        end
        if stdOut and stdOut ~= '' then
            obj.logger.i('stdout for ' .. logTitle .. ':\n' .. stdOut)
        end
        if stdErr and stdErr ~= '' then
            obj.logger.w('stderr for ' .. logTitle .. ':\n' .. stdErr)
        end
    end

    hs.task.new(path, taskCallback, arguments):start()
end

return obj
