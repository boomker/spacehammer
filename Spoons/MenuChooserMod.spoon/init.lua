local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MenuChooser"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- MenuChooser.chooseMenuItem()
--- Function
--- Shows a chooser containing all menu items of the current (frontmost) application.
function obj.chooseMenuItem()
    local app = hs.application.frontmostApplication()
    app:getMenuItems(function(menu)
        local choices = {}
        local function findChoices(pathstr, path, list)
            for _, item in pairs(list) do
                local newpathstr
                if pathstr then
                    newpathstr = pathstr .. ' -> ' .. (item.AXTitle or '')
                else
                    newpathstr = item.AXTitle
                end
                local newpath = {}
                for i, title in ipairs(path) do
                    newpath[i] = title
                end
                newpath[#newpath + 1] = item.AXTitle
                if item.AXChildren then
                    findChoices(newpathstr, newpath, item.AXChildren[1])
                elseif item.AXEnabled and item.AXTitle and (not (item.AXTitle == '')) then
                    choices[#choices + 1] = {
                        text = newpathstr,
                        path = newpath
                    }
                end
            end
        end

        findChoices(nil, {}, menu)
        local chooser = hs.chooser.new(function(selected)
            if selected then
                app:selectMenuItem(selected.path)
            end
        end)
        chooser:choices(choices)
        chooser:placeholderText('menu item')
        chooser:show()
    end)
end

return obj
