if SERVER then
	AddCSLuaFile()
	return 
end

require 'sty'

fw.dep(CLIENT, 'fonts')

fw.ui = {}

fw.ui.const_darkgrey = Color(50, 50, 50)
fw.ui.const_lightgrey = Color(155, 155, 155)
fw.ui.const_white = Color(255, 255, 255)
fw.ui.const_black = Color(0, 0, 0)

fw.ui.const_panel_background = Color(75, 75, 75)
fw.ui.const_frame_background = Color(54, 54, 54)

fw.include_cl 'vgui_dropshadow_cl.lua'
fw.include_cl 'vgui_content_cl.lua'