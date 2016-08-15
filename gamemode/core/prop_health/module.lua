if SERVER then
	AddCSLuaFile()
end

-- load internal dependencies
fw.dep(SHARED, "hook")
fw.dep(SERVER, "data")

-- proper include system
fw.include_sh "phealth_sh.lua"