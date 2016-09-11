if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.faction = fw.faction or {}

-- load internal dependencies
fw.dep(SHARED, "notif")
fw.dep(SHARED, "hook")
fw.dep(SERVER, "data")
fw.dep(SHARED, "teams")
fw.dep(SERVER, "chat_commands")
fw.dep(SERVER, "zones")

-- TEMPORARILY DISABLED

-- proper include system
fw.include_sv "bank_sv.lua"
-- fw.include_cl "cl_ents.lua"
