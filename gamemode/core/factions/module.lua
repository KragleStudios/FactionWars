if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.faction = fw.faction or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')

-- TEMPORARILY DISABLED

-- proper include system
-- fw.include_sh 'bank_sh.lua'
-- fw.include_cl 'bank_cl.lua'
-- fw.include_sv 'bank_sv.lua'
-- fw.include_cl 'cl_ents.lua'