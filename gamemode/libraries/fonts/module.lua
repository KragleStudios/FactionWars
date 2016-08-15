--
-- DEFINES FONTS TO BE USED THROUGHOUT THE GAMEMODE
--

if SERVER then
	AddCSLuaFile()
	return
end

require "sty"

fw.fonts = {}

fw.fonts.default = sty.Font {
	font = "Roboto",
	weight = 100
}

fw.fonts.default_shadow = sty.Font {
	font = "Roboto",
	weight = 100,
	shadow = true
}

fw.fonts.default_compact = sty.Font {
	font = "Roboto Condensed",
	weight = 100
}

fw.fonts.default_compact_shadow = sty.Font {
	font = "Roboto Condensed",
	weight = 100,
	shadow = true
}
