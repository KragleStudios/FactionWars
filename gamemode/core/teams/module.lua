-- create the exported table
fw.team = fw.team or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')

-- proper include system
fw.include_sh 'sh_teams.lua'
fw.include_sv 'sv_teams.lua'
fw.include_sh 'sh_team_overrides.lua'
-- fw.include_cl 'cl_teams.lua'

-- should really be placed somewhere else
fw.include_sh 'teams.lua'