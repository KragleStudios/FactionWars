fw.team.spawns = fw.team.spawns or {}

util.AddNetworkString("fw_agendaupdate")
util.AddNetworkString("playerChangeTeam")

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



function fw.team.updateAgenda(ply, faction, text)
	fw.team.factionAgendas[faction] = text

	--todo: optimize
	local f_plys = player.GetAll() -- fw.team.getFactionPlayers(faction)
	for k,v in ipairs(f_plys) do
		v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "The agenda has been updated by ", ply:Nick())

		net.Start("fw_agendaupdate")
			net.WriteString(text)
			net.WriteUInt(faction, 32)
		net.Send(v)			
	end

	return true
end

hook.Add("FWChatLibraryLoaded", "LoadCMD", function()
	fw.chat.addCMD("agenda", "Sets the agenda for your faction if you're the boss.", function(ply, text)
		local t = fw.team.list[ply:Team()]
		if (not t) then return end

		--duh
		if (not t.boss) then ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "You aren't the correct rank for this!") return end

		--just a check. it should go through if the team is set up correctly
		if (not t.faction or not t.factionOnly) then ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "You need to be in a faction to set the agenda! If you are, notify a dev!") return end

		local agenda = fw.team.updateAgenda(ply, t.faction, text)

		if (agenda) then 
			ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "You have succesfully set the agenda!")

			return
		end

		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "Uh oh, something went wrong!")
	end):addParam('message', 'string')
end)

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
	ply:SetupHands()
end)

-- sets the players team to 'Civilian' on the first spawn
fw.hook.Add("PlayerInitialSpawn", "SetTeam", function(ply)
	ply:FWConPrint("setting your team to team citizen")
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