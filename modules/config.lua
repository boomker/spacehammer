---@diagnostic disable: lowercase-global
-- 默认加载的功能模块
defaultConfig = {{
    -- 配置版本号
    -- 每次新增功能项，需将版本号加 1
    configVersion = '7'
}, {
    module = 'modules.winman',
    name = '窗口管理',
    enable = true 
}, {
    module = 'modules.application',
    name = '应用切换',
    enable = true
}, {
    module = 'modules.emoji',
    name = '表情包搜索',
    enable = true
}, {
    module = 'modules.password',
    name = '密码粘贴',
    enable = true
}, {
    module = 'modules.input-method',
    name = '输入法切换',
    enable = false
}, {
    module = 'modules.network',
    name = '实时网速',
    enable = true
}, {
    module = 'modules.keystroke-visualizer',
    name = '按键回显',
    enable = false
}, {
    -- module = 'modules.hotkey',
    module = 'modules.ksheet',
    name = '快捷键列表查看',
    enable = true
}, {
    module = 'modules.clipboardtool',
    name = '剪贴板工具',
    enable = true
}, {
    module = 'modules.remapkey',
    name = '自定义按键映射',
    enable = true
}, {
    module = 'modules.remind',
    name = '提醒下班',
    enable = false
}, {
    module = 'modules.jsonFormat',
    name = 'JSON格式化',
    enable = true
}, {
    module = 'modules.update',
    name = '自动检查更新',
    enable = true
}}

base_path = os.getenv("HOME") .. '/.hammerspoon/'
-- 本地配置文件路径
config_path = base_path .. '.config'

-- 加载本地配置文件
function loadConfig()
    -- 以可读写方式打开文件
    local file = io.open(config_path, 'r+')
    -- 文件不存在
    if file == nil then
        -- 创建文件
        file = io.open(config_path, 'w+')
    end
    -- 读取文件所有内容
    local config = file:read('*a')
    -- 配置文件中不存在配置
    if config == '' then
        -- 读取默认配置
        config = serialize(defaultConfig)
    end
    file:close()
    return config
end

function saveConfig(config)
    -- 清空文件内容，然后写入新的文件内容
    file = io.open(config_path, 'w+')
    file:write(serialize(config))
    file:close()
end