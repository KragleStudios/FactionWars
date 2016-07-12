-- create the exported table
fw.ents = fw.ents or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')

-- proper include system
fw.include_sh 'sh_ents.lua'
fw.include_sv 'sv_ents.lua'
-- fw.include_cl 'cl_ents.lua'

-- should really be placed somewhere else
fw.include_sh 'items.lua'