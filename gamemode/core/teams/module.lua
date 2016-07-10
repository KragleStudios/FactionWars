if SERVER then
	AddCSLuaFile()

	include("sh_teams.lua")
	include('sv_teams.lua')
	include("teams.lua")

	AddCSLuaFile("sh_teams.lua")
	AddCSLuaFile("cl_teams.lua")
	AddCSLuaFile("teams.lua")
else
	include("sh_teams.lua")
	include("cl_teams.lua")
	include("teams.lua")
end

-- load internal dependencies
fw.dep(SHARED, 'hook')
fw.dep(SERVER, 'data')

-- load self

