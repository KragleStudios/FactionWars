--
-- DEFINES FONTS TO BE USED THROUGHOUT THE GAMEMODE
--

if SERVER then 
	AddCSLuaFile()
	return 
end

require 'sty'

fw.fonts = {}

fw.fonts.default = sty.Font {
	font = 'Roboto',
	weight = 100
}