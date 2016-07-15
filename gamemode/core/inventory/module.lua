if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.inv = fw.inv or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')
fw.dep(SHARED, 'items')
fw.dep(CLIENT, 'fonts')
fw.dep(CLIENT, 'ui')

-- proper include system
fw.include_sh 'inventory_sh.lua'
fw.include_sv 'inventory_sv.lua'
fw.include_cl 'inventory_cl.lua'
-- fw.include_cl 'cl_ents.lua'