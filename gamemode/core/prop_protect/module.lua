if (SERVER) then AddCSLuaFile() end

-- create the exported table
fw.pp = fw.pp or {}

-- load internal dependencies
fw.dep(SHARED, 'hook')

-- proper include system
fw.include_sv 'prop_protect_sv.lua'
fw.include_sh 'prop_protect_sh.lua'
fw.include_cl 'prop_protect_cl.lua'
