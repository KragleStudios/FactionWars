if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.team = fw.team or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')

-- load core team system
fw.include_sh 'teams_sh.lua'
fw.include_sv 'teams_sv.lua'
fw.include_sh 'team_overrides_sh.lua'

-- load faction system
fw.include_sh 'factions_sh.lua'


-- should really be placed somewhere else
fw.include_sh 'teams.lua'