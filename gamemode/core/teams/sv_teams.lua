util.AddNetworkString("playerChangeTeam")

fw.team.spawns = fw.team.spawns or {}

-- fw.team.registerSpawn - Registers spawn points to be used in player spawns. Multiple points can be registered
-- @param team_textID:string - the string_id found in the team configuration
-- @param vector:string - the vector position of the new spawn point
-- @param angle:angle - the angle of the new spawn point
-- @ret nothing
function fw.team.registerSpawn(team_textID, vector, angle)
	local points = {}
	if (fw.team.spawns[team_textID]) then
		points = fw.team.spawns[team_textID]
	end

	table.insert(points, {vector, angle})

	fw.team.spawns[team_textID] = points
end

-- fw.team.findBestSpawn - Finds an open spawn point for the team, upon player spawning
-- @param team_textID:string - the string_id found in the team configuration
-- @ret nothing
function fw.team.findBestSpawn(team_textID)
	if (fw.team.spawns[team_textID]) then
		for k,v in ipairs(fw.team.spawns[team_textID]) do
			local ent = ents.FindInSphere(v[1], 40)
			if (#ent > 0) then
				continue
			else
				return v
			end
		end
	end

	return false
end

-- handles all spawning related functionality 
hook.Add("PlayerSpawn", "TeamSpawn", function(ply)
	local plyT = ply:getTeam()
	if (!plyT) then
		//NOTIFY UNABLE TO OBTAIN PLAYER'S TEAM
		return
	end

	local t = fw.team.list[plyT]
	if (!t) then
		//NOTIFY UNABLE TO FIND TEAM
		return
	end

	local spawn = t.onSpawn

	ply:SetModel(ply.pref_model or t.models[1])
	for k,v in ipairs(t.weapons) do
		ply:Give(v)
	end

	local sp = fw.team.findBestSpawn(t.stringID)
	if (sp) then
		ply:SetPos(sp[1])
		ply:SetAngles(sp[2])
	end

	spawn(t, ply)
end)

-- sets the players team to 'Civilian' on the first spawn
hook.Add("PlayerInitialSpawn", "SetTeam", function(ply)
	local t = fw.team.getByString("civilian")

	ply:SetModel(ply.pref_model or table.Random(t.models))
	for k,v in ipairs(t.weapons) do
		ply:Give(v)
	end

	local sp = fw.team.findBestSpawn(t.stringID)
	if (sp) then
		ply:SetPos(sp[1])
		ply:SetAngles(sp[2])
	end

	ply.team = t.ind
	ply:SetNWInt("team_id", t.ind)

	table.insert(fw.team.list[t.ind].players, ply)
end)

-- handles all death related functionality
hook.Add("PlayerDeath", "TeamSpawn", function(ply)
	local plyT = ply:getTeam()
	if (!plyT) then
		//NOTIFY UNABLE TO OBTAIN PLAYER'S TEAM
		return
	end

	local t = fw.team.list[plyT]
	if (!t) then
		//NOTIFY UNABLE TO FIND TEAM
		return
	end

	local death = t.onDeath

	ply:StripWeapons()

	death(t, ply)
end)

