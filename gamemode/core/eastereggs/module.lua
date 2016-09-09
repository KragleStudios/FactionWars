if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, "hook")

fw.include_sh "egg_sh.lua"
fw.include_sv "egg_sv.lua"
