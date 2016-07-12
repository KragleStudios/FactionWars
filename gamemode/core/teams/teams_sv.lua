fw.team.spawns = fw.team.spawns or {}

-- fw.team.registerSpawn - Registers spawn points to be used in player spawns. Multiple points can be registered
-- @param team_textID:string - the string_id found in the team configuration
-- @param vector:string - the vector position of the new spawn point
-- @param angle:angle - the angle of the new spawn point
-- @ret nothing
function fw.team.registerSpawn(team_textID, vector, angle, faction)
	if not fw.team.spawns[team_textID] then
		fw.team.spawns[team_textID] = {}
	end
	local points = fw.team.spawns[team_textID]

	table.insert(points, {
		pos = vector, 
		angle = angle, 
		faction = faction
	})

	fw.team.spawns[team_textID] = points
end

-- fw.team.findBestSpawn - Finds an open spawn point for the team, upon player spawning
-- @param team_textID:string - the string_id found in the team configuration
-- @ret nothing
function fw.team.findBestSpawn(team_textID, faction)
	if fw.team.spawns[team_textID] then
		for k,v in ipairs(fw.team.spawns[team_textID]) do
			if faction ~= nil and v.faction ~= faction then continue end 

			-- this is pretty expensive
			local ents = ents.FindInSphere(v.pos, 40)
			if (#ents > 0) then
				continue
			else
				return v
			end

		end
	end

	return false
end

-- fw.team.demotePlayer - force demotes a player back to the citizen team
-- @param py:player - the player to demote
-- @ret nothing
function fw.team.demotePlayer(ply)
	if (not IsValid(ply)) then return end
	
	fw.team.playerChangeTeam(ply, TEAM_CIVILIAN:getID(), table.Random(TEAM_CIVILIAN:getModels()))
end


-- fw.team.addPlayerToTeam - sets a player to a job, regardless of restrictions
-- @param ply:player - the player to set the job on
-- @param team_id_num:integer - the index value in the master team table, found by TEAM_*:getID()
-- @ret nothing
function fw.team.addPlayerToTeam(ply, team_id_num)
	fw.team.playerChangeTeam(ply, team_id_num, nil, true)
end

-- fw.team.setPreferredModel - sets the preferred model for the team
-- @param team_id:int
-- @param ply:Player
-- @param model:string
-- @ret nothing
function fw.team.setPreferredModel(team_id, ply, model)
	local team = fw.team.getByIndex(team_id)
	if not team then 
		pl:FWConPrint("no such team \'" .. tostring(args[1]) .. "\'")
		return
	end

	if not table.HasValue(team:getModels(), args[2]) then
		pl:FWConPrint("model " .. tostring(args[2]) .. " not available for team " .. tostring(args[1]))
		return 
	end

	-- update the preferred model!
	ply:GetFWData().preferred_models[t.stringID] = pref_model
end

-- playerChangeTeam - handles player team switching
-- @param ply:player object - the player object switching teams
-- @param targ_team:int - the index of the team in the table
-- @param pref_model:string - the model selected on the switch team screen is sent here
-- @param optional forced:bool - should we ignore canjoin conditions?
-- @ret nothing
function fw.team.playerChangeTeam(ply, targ_team, pref_model, forced)
	local canjoin, message = hook.Call("CanPlayerJoinTeam", GAMEMODE, ply, targ_team)
	if (not forced and not canjoin) then
		-- TODO: notify can't join team
		return false 
	end

	local t = fw.team.list[targ_team]
	if not t then
		-- TODO: notify player the team doesn't exist
		fw.print("no such team! " .. targ_team)
		return false 
	end

	-- find a good pref_model
	if not pref_model then
		pref_model = ply:GetFWData().preferred_models and ply:GetFWData().preferred_models[t.stringID] or table.Random(t.models)
	end

	-- set the data
	if (SERVER) then
		ply:SetTeam(targ_team)
		ply:GetFWData().team = targ_team 
		if not ply:GetFWData().preferred_models then
			ply:GetFWData().preferred_models = {}
		end
		ply:GetFWData().preferred_models[t.stringID] = pref_model
		ply:GetFWData().pref_model = pref_model

		-- TODO: NOTIFY PLAYER CHANGED TEAM
		ply:Spawn()
	end
end


-- handles all spawning related functionality 
fw.hook.Add("PlayerSpawn", "TeamSpawn", function(ply)
	local team = ply:Team()
	local t = fw.team.list[team]
	if (not t) then
		--NOTIFY UNABLE TO FIND TEAM
		return
	end

	ply:StripWeapons()

	hook.Call('PlayerLoadout', GAMEMODE, ply)
	hook.Call('PlayerSetModel', GAMEMODE, ply)
	
	local fac = nil
	if (ply:inFaction()) then 
		fac = ply:getFaction()
	end

	-- TODO: use PlayerSelectSpawn
	local sp = fw.team.findBestSpawn(t.stringID, fac)
	if (sp) then
		ply:SetPos(sp.pos)
		ply:SetAngles(sp.angle)
	end

	if t.onSpawn then
		t:onSpawn(ply)
	end
end)


fw.hook.Add('PlayerLoadout', function(ply)
	local team = ply:Team()
	local t = fw.team.list[team]
	if (not t) then
		--NOTIFY UNABLE TO FIND TEAM
		return
	end

	for k,v in ipairs(t.weapons) do
		ply:Give(v)
	end
end)

fw.hook.Add('PlayerSetModel', function(ply)
	local team = ply:Team()
	local t = fw.team.list[team]
	if (not t) then
		--NOTIFY UNABLE TO FIND TEAM
		return
	end

	ply:SetModel(ply.pref_model or table.Random(t.models))
end)

-- sets the players team to 'Civilian' on the first spawn
fw.hook.Add("PlayerInitialSpawn", "SetTeam", function(ply)
	fw.print("setting your team to team citizen")
	fw.team.playerChangeTeam(ply, TEAM_CIVILIAN:getID(), nil, true)
end)

-- handles all death related functionality
fw.hook.Add("PlayerDeath", "TeamSpawn", function(ply)
	local team = ply:Team()

	local t = fw.team.list[team]
	if (!t) then
		return
	end

	ply:StripWeapons()

	if t.onDeath then
		t:onDeath(ply)
	end
end)


--
-- CONSOLE COMMANDS
-- 

concommand.Add("fw_team_preferredModel", function(pl, cmd, args)
	if #args < 2 then pl:FWConPrint("too few argumetns") return end
	local team = fw.team.getByStringID(args[1])
	fw.team.setPreferredModel(team:getID(), pl, args[2])
end)