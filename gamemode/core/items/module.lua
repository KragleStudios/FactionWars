if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.ents = fw.ents or {}
fw.inv = fw.inv or {}

-- load internal dependencies
fw.dep(SHARED, "notif")
fw.dep(SHARED, "hook")
fw.dep(SERVER, "data")
fw.dep(SHARED, "prop_protect")

-- proper include system
fw.include_sh "sh_ents.lua"
fw.include_sv "sv_ents.lua"
fw.include_sv "sv_inventory.lua"

-- should really be placed somewhere else
fw.include_sh "items.lua"
