if SERVER then AddCSLuaFile() end 

-- dependencies
fw.dep(SHARED, "hook")

-- load files
fw.include_sv "core_sv.lua"
fw.include_cl "core_cl.lua"