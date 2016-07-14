if SERVER then
	AddCSLuaFile()
	return 
end

require 'sty'

fw.dep(CLIENT, 'fonts')

fw.include_cl 'vgui_dropshadow_cl.lua'