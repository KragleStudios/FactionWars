if SERVER then AddCSLuaFile() end

-- load external dependencies 
require 'sty'

-- load modular dependencies 
fw.dep(CLIENT, 'fonts')

-- client side constants 
fw.ui = {}

fw.ui.const_darkgrey = Color(50, 50, 50)
fw.ui.const_lightgrey = Color(155, 155, 155)
fw.ui.const_white = Color(255, 255, 255)
fw.ui.const_black = Color(0, 0, 0)


fw.ui.TOP = 1
fw.ui.BOTTOM = 2
fw.ui.LEFT = 3
fw.ui.RIGHT = 4
fw.ui.CENTER = 5

fw.ui.const_panel_background = Color(45, 45, 45)
fw.ui.const_frame_background = Color(34, 34, 34)
fw.ui.const_nesting_lighten_rate = 5

fw.include_cl 'vgui_dropshadow_cl.lua'
fw.include_cl 'vgui_content_cl.lua'
fw.include_cl 'vgui_tableview_cl.lua'
