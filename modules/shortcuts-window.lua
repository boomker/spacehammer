
-- 窗口管理快捷键配置
windows = {
    -- 同一应用的所有窗口自动网格式布局 
    same_application_auto_layout_grid = { prefix = { "Ctrl", "Option" }, key = "Z", message = "" },
    -- 同一应用的所有窗口自动水平均分或垂直均分 
    same_space_auto_layout_grid = { prefix = { "Ctrl", "Option" }, key = "X", message = "" },
    -- 同一工作空间下的所有窗口自动网格式布局
    same_application_auto_layout_horizontal_or_vertical = { prefix = { "Ctrl", "Option" }, key = "A", message = "" },
    -- 同一工作空间下的所有窗口自动水平均分或垂直均分 
    same_space_auto_layout_horizontal_or_vertical = { prefix = { "Ctrl", "Option" }, key = "S", message = "" },
    -- 左半屏
    left = {prefix = {"Ctrl", "Option"}, key = "Left", message = "Left Half"},
    -- 右半屏
    right = {prefix = {"Ctrl", "Option"}, key = "Right", message = "Right Half"},
    -- 上半屏
    up = {prefix = {"Ctrl", "Option"}, key = "Up", message = "Up Half"},
    -- 下半屏
    down = {prefix = {"Ctrl", "Option"}, key = "Down", message = "Down Half"},
    -- 左上角
    top_left = {prefix = {"Ctrl", "Option"}, key = "U", message = "Top Left"},
    -- 右上角
    top_right = {prefix = {"Ctrl", "Option"}, key = "I", message = "Top Right"},
    -- 左下角
    left_bottom = {prefix = {"Ctrl", "Option"}, key = "J", message = "Left Bottom"},
    -- 右下角
    right_bottom = {prefix = {"Ctrl", "Option"}, key = "K", message = "Right Bottom"},
    -- 1/9
    one = {prefix = {"Ctrl", "Option"}, key = "1", message = "1/9"},
    -- 2/9
    two = {prefix = {"Ctrl", "Option"}, key = "2", message = "2/9"},
    -- 3/9
    three = {prefix = {"Ctrl", "Option"}, key = "3", message = "3/9"},
    -- 4/9
    four = {prefix = {"Ctrl", "Option"}, key = "4", message = "4/9"},
    -- 5/9
    five = {prefix = {"Ctrl", "Option"}, key = "5", message = "5/9"},
    -- 6/9
    six = {prefix = {"Ctrl", "Option"}, key = "6", message = "6/9"},
    -- 7/9
    seven = {prefix = {"Ctrl", "Option"}, key = "7", message = "7/9"},
    -- 8/9
    eight = {prefix = {"Ctrl", "Option"}, key = "8", message = "8/9"},
    -- 9/9
    nine = {prefix = {"Ctrl", "Option"}, key = "9", message = "9/9"},
    -- 左 1/3（横屏）或上 1/3（竖屏）
    left_1_3 = {prefix = {"Ctrl", "Option"}, key = "D", message = "Left 1/3(Horizontal screen) Or Top 1/3(Vertical screen)"},
    -- 中 1/3
    middle = {prefix = {"Ctrl", "Option"}, key = "F", message = "Middle 1/3"},
    -- 右 1/3（横屏）或下 1/3（竖屏）
    right_1_3 = {prefix = {"Ctrl", "Option"}, key = "G", message = "Right 1/3(Horizontal screen)Or Bottom 1/3(Vertical screen)"},
    -- 左 2/3（横屏）或上 2/3（竖屏）
    left_2_3 = {prefix = {"Ctrl", "Option"}, key = "E", message = "Left 2/3(Horizontal screen) Or Top 2/3(Vertical screen)"},
    -- 右 2/3（横屏）或下 2/3（竖屏）
    right_2_3 = {prefix = {"Ctrl", "Option"}, key = "T", message = "Right 2/3(Horizontal screen)Or Bottom 2/3(Vertical screen)"},
    -- 居中
    center = {prefix = {"Ctrl", "Option"}, key = "C", message = "Center"},
    -- 等比例放大窗口
    zoom = {prefix = {"Ctrl", "Option"}, key = "=", message = "Zoom Window"},
    -- 等比例缩小窗口
    narrow = {prefix = {"Ctrl", "Option"}, key = "-", message = "Narrow Window"},
    -- 最大化
    max = {prefix = {"Ctrl", "Option"}, key = "Return", message = "Max Window"},
    -- 将窗口移动到上方屏幕
    to_up = {prefix = {"Ctrl", "Option", "Command"}, key = "Up", message = "Move To Up Screen"},
    -- 将窗口移动到下方屏幕
    to_down = {prefix = {"Ctrl", "Option", "Command"}, key = "Down", message = "Move To Down Screen"},
    -- 将窗口移动到左侧屏幕
    to_left = {prefix = {"Ctrl", "Option", "Command"}, key = "Left", message = "Move To Left Screen"},
    -- 将窗口移动到右侧屏幕
    to_right = {prefix = {"Ctrl", "Option", "Command"}, key = "Right", message = "Move To Right Screen"}
}