-- inputmethodId: 输入法唯一标示ID, 即对应输入法 App 的 BundleId

-- ===== 输入法自动切换和手动切换快捷键配置 ===== --
input_method_config = {

    manualSwitch = false, -- 是否开启手动切换输入法
    notifiyStatus = false, -- 是否开启右下角状态显示
    input_methods = {
        -- 输入法 BundleId 配置
        -- sogouId = 'com.sogou.inputmethod.sogou.pinyin',
        -- abcId = 'com.apple.keylayout.ABC',
        -- shuangpinId = 'com.apple.inputmethod.SCIM.Shuangpin',

        -- 以下键名(abc, chinese)不能改
        abc = {
            prefix = HyperKey,
            key = " ",
            -- key = "X",
            message = "切换到英文输入法",
            inputmethodId = "com.apple.keylayout.ABC",
        },
        chinese = {
            prefix = HyperKey,
            key = " ",
            -- key = "C",
            message = "切换到rime输入法",
            inputmethodId = "im.rime.inputmethod.Squirrel.Hans",
        },
        -- chinese = { prefix = HyperKey, key = "R", message = "Rime XHUP", inputmethodId = "com.sogou.inputmethod.sogou.pinyin" },
    },

    --  以下 App 聚焦后自动切换到目标输入法, 需要配置目标应用名称或应用的 BundleId
    abc_apps = {
        -- "com.microsoft.VSCode", -- VSCode的应用名为"Code"
        -- 从 CLI 启动的APP窗口程序, 如若是别名, 需将别名添加到下面
        "Code",
        "PyCharm",
        "com.jetbrains.intellij",
        "Terminal",
        "com.googlecode.iterm2",
        "org.alacritty",
        "com.neovide.neovide",
        "nvide",
        "goneovim",
        "com.kapeli.dashdoc",
        "com.runningwithcrayons.Alfred",
        "Raycast",
        "Obsidian",
    },

    chinese_apps = {
        -- "com.tencent.xinWeChat", -- 这是微信的 BundleId , 应用名称为"WeChat", 应用标题为 "微信", 均支持
        "微信",
        "企业微信",
        "QQ",
        "网易云音乐",
        "Typora",
        "com.yinxiang.Mac",
        "com.microsoft.edgemac",
        "com.kingsoft.wpsoffice.mac",
        -- "com.raycast.macos",
    },
}
