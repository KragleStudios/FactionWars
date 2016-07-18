fw.team.spawns = fw.team.spawns or {}

-- playerChangeTeam - handles player team switching
-- @param ply:player object - the player object switching teams
-- @param targ_team:int - the index of the team in the table
-- @param optional forced:bool - should we ignore canjoin conditions?
-- @ret nothing
function fw.team.playerChangeTeam(ply, targ_team, forced)
	local canjoin, message = hook.Call("CanPlayerJoinTeam", GAMEMODE, ply, targ_team)
	
	local t = fw.team.list[targ_team]
	if not t then
		ply:FWChatPrintError("no such team ", tostring(targ_team))
		return false 
	end

	if (not forced and not canjoin) then
		ply:FWChatPrintError(message or ("can't join team " .. t:getName()))
		return false 
	end

	local pref_model = ply:GetFWData().preferred_models and ply:GetFWData().preferred_models[t.stringID] or table.Random(t.models)

	-- remove player if they are the faction boss
	if ply:isFactionBoss() then
		fw.notif.chatPrint(player.GetAll(), "Player ", ply, " is no longer the boss of " .. fw.team.getFactionByID(ply:getFaction()):getName())
		fw.team.removeFactionBoss(ply:getFaction())
	end

	local prevTeam = ply:Team()

	-- set the player's team and preferred model data
	ply:SetTeam(targ_team)
	if not ply:GetFWData().preferred_models then
		ply:GetFWData().preferred_models = {}
	end
	ply:GetFWData().preferred_models[t.stringID] = pref_model

	-- respawn the player
	ply:Spawn()

	-- make the player the faction boss if their team is flagged as a boss team
	if t.boss then
		-- make the player the new boss of the faction!
		fw.team.setFactionBoss(ply:getFaction(), ply)
	end

	hook.Run('PlayerChangedTeam', prevTeam, ply:Team())
end


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

-- handles the ability of whether or not a player can join a team
fw.hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	local t = fw.team.list[targ_team]
	if (not t) then 
		return false 
	end
	
	-- enforce t.max players
	if t.max then
		if (t.factionOnly and t.faction) then
			local count = 0
			for k,v in pairs(t:getPlayers()) do
				if (v:getFaction() == t.faction) then
					count = count + 1
				end
			end

			if (count == t.max) then
				return false
			end
		elseif (#t:getPlayers() >= t.max) then
			return false
		end 
	end

	-- can't join a team you're already on
	if (ply:Team() == targ_team) then 
		return false 
	end

	-- SUPPORT FOR FACTION ONLY JOBS
	if ((t.factionOnly and not t.faction) and not ply:getFaction()) then 
		return false
	end 
	-- notify incorrect faction
	if ((t.factionOnly and t.faction) and (ply:getFaction() != t.faction)) then
		return false
	end

	local canjoin = t.canJoin
	if canjoin then
		if (istable(canjoin)) then
			return table.HasValue(canjoin, ply:Team())
		else
			return canjoin(t, ply) ~= false
		end
	end
	return true
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

-- pay the team salary
timer.Create('fw.teams.pay', fw.config.payrollTime, 0, function()
	for k,v in pairs(player.GetAll()) do
		local t = fw.team.list[v:Team()]
		if t and t.salary ~= 0 then
			v:addMoney(t.salary)
			v:FWChatPrint(color_black, "[Salary]: ", color_white, " You were paid $" .. t.salary)
		end
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

--
-- CHAT COMMANDS FOR FACTION
-- TODO: MOVE THESE TO THEIR OWN SEPERATE FILE
--

--vote to remove a user from faction
fw.chat.addCMD("factionkick", "Vote to remove a user from a faction", function(ply, target)

	if ply == target then
		ply:FWChatPrintError("You can't remove yourself!")
		return 
	end

	if not ply:inFaction() then
		ply:FWChatPrintError("You aren't in a faction!")
		return 
	end

	if (target:getFaction() ~= ply:getFaction()) then 
		ply:FWChatPrintError(Color(0, 0, 0), "This person isn't in the same faction as you!")
		return 
	end

	local faction = ply:getFaction()
	local players = fw.team.getFactionPlayers(faction)

	if ply:isFactionBoss() then
		fw.notif.chatPrint(players, ply, " forcefully removed ", target, " from the faction.")
		fw.team.removePlayerFromFaction(target)
		return 
	end

	fw.vote.createNew("Vote Remove User: Faction", "Remove ".. target:Nick().." from faction?", players, 
		function(decision, vote, results) 
			if (not IsValid(target)) then return end

			if (decision == "Yes") then
				fw.team.removePlayerFromFaction(target)
				fw.notif.chatPrint(players, color_black, '[Votes]: ', color_white, target:Nick(), " was removed from the faction!")
			else
				fw.notif.chatPrint(players, color_black, '[Votes]: ', color_white, target:Nick(), " was not removed!")
			end
		end, "Yes", "No", 15)

end):addParam("target", "player")

--vote to demote a player to civilian within a faction
fw.chat.addCMD("demote", "Vote to demote a user", function(ply, target)
	local faction = ply:getFaction()
	local players = player.GetAll()

	if (target:getFaction() ~= ply:getFaction()) then 
		ply:FWChatPrintError("This person isn't in the same faction as you!")
		return 
	end
	
	if (faction == target:getFaction()) then
		players = fw.team.getFactionPlayers(faction)
	end

	if ply:isFactionBoss() then
		fw.notif.chatPrint(player.GetAll(), ply, " forcefully demoted ", target, "!")
		fw.team.playerChangeTeam(target, TEAM_CIVILIAN:getID())
		return
	end

	fw.vote.createNew("Vote Demote User", "Demote ".. target:Nick().."?", players, 
		function(decision, vote, results) 
			if (not IsValid(target)) then return end

			if (decision == "Yes") then
				fw.team.playerChangeTeam(target, TEAM_CIVILIAN:getID())
				fw.notif.chatPrint(player.GetAll(), target:Nick(), " was demoted to Citizen!")
			else
				fw.notif.chatPrint(player.GetAll(), target:Nick(), " was not demoted!")
			end
		end, "Yes", "No", 15)

end):addParam("target", "player")