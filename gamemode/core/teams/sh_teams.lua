fw.team = fw.team or {}
fw.team.list = fw.team.list or {}

-- fw.team.register - Registers a new team to the system
-- @param name:string - the name of the team, ie: "Civilian", "Police Officer"
-- @param tbl:tbl - the table data of the new team
-- @ret a meta object of the new team assigned to the variable in the configuration
function fw.team.register(name, tbl) // DO CHECKS FOR TEAM CORRECT
	tbl.players = {}
	tbl.job = name

	local index = table.insert(fw.team.list, tbl)
	fw.team.list[index].ind = index
	local t = tbl
	local team_meta = {
		getStringID = function() 
				return tbl.stringID or name
			end,
		getModels = function()
				return tbl.models or {}
			end,
		getWeapons = function()
				return tbl.weapons or {}
			end,
		getID = function()
				return index
			end,
		getPlayers = function()
				return fw.team.list[index].players or {}
			end,
		getInfo = function()
				return tbl
			end,
	}

	team_meta.__index = team_meta
	setmetatable(t, team_meta)

	return t
end

concommand.Add("test", function()
	PrintTable(TEAM_CIVILIAN:getPlayers())
end)

-- fw.team.getByString - Gets a team's data by the string used, "civilian", "police_officer"
-- @param team_textID:string - the string_id found in the team configuration
-- @ret the table team
function fw.team.getByString(team_textID)
	for k,v in ipairs(fw.team.list) do
		if (v.stringID == team_textID) then
			return v
		end
	end

	Error("FAILED TO FIND TEAM")
end

-- fw.team.demotePlayer - force demotes a player back to the citizen team
-- @param py:player - the player to demote
-- @ret nothing
function fw.team.demotePlayer(ply)
	if (!IsValid(ply)) then return end
	
	playerChangeTeam(ply, TEAM_CIVILIAN:getID(), table.Random(TEAM_CIVILIAN:getModels()))
end

-- fw.team,setPlayer - sets a player to a job, regardless of restrictions
-- @param ply:player - the player to set the job on
-- @param team_id_num:integer - the index value in the master team table, found by TEAM_*:getID()
-- @ret nothing
function fw.team.setPlayer(ply, team_id_num)
	if (!IsValid(ply) or !team_textID) then return end
	
	local team = fw.team.list[team_textID]
	if (!team) then return end
	
	playerChangeTeam(ply, team_id_num, table.Random(team.models), true)
end

-- handles the ability of whether or not a player can join a team
hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	if (!targ_team or !ply:Alive()) then
		//NOTIFY NO TARG_TEAM
		return false
	end
	
	local t = fw.team.list[targ_team]
	if (!t) then 
		//NOTIFY TEAM NOT FOUND
		return false 
	end
	
	local canjoin = t.canJoin

	local max = t.max or 0
	if (max != 0) then
		if (#t.players + 1 > max) then 
			return false
		end
	end
	
	if (ply:getTeam() == targ_team) then return false end

	// SUPPORT FOR FACTION ONLY JOBS
	if ((t.factionOnly and !t.faction) and ply:getFaction() == NULL) then 
		return false
	end 
	//notify incorrect faction
	if ((t.factionOnly and t.faction) and (ply:getFaction() != t.faction)) then
		return false
	end

	if (istable(canjoin)) then
		for k,v in ipairs(canjoin) do
			if (ply:getTeam() == v) then
				return true
			end
		end
	else
		local result = canjoin(t, ply)
		return result
	end
end)

-- playerChangeTeam - handles player team switching
-- @param ply:player object - the player object switching teams
-- @param targ_team:int - the index of the team in the table
-- @param pref_model:string - the model selected on the switch team screen is sent here
-- @param optional forced:bool - should we ignore canjoin conditions?
-- @ret nothing
function playerChangeTeam(ply, targ_team, pref_model, forced)
	if (!targ_team) then
		// NOTIFY TARG_TEAM NOT FOUND
		return
	end

	local canjoin = hook.Call("CanPlayerJoinTeam", FW, ply, targ_team)
	if (!forced and !canjoin) then
		//NOTIFY CAN'T JOIN TEAM
		return false 
	end

	local t = fw.team.list[targ_team]
	t.players = t.players or {}
	table.insert(fw.team.list[targ_team].players, ply)

	local last_team = fw.team.list[ply:getTeam()]
	if (!last_team) then return end
	table.RemoveByValue(fw.team.list[ply:getTeam()].players, ply)

	if (SERVER) then
		ply.last_team = ply.team
		ply.team = targ_team
		ply:SetNWInt("team_id", targ_team)
		ply.pref_model = pref_model

		//NOTIFY PLAYER CHANGED TEAM

		ply:Kill()
	end
end
if (SERVER) then
	net.Receive("playerChangeTeam", function(l, client)
		local team_id = net.ReadInt(32)
		local model = net.ReadString()

		playerChangeTeam(client, team_id, model)
	end)
end


local player = FindMetaTable("Player")

-- gets the player's index team id
function player:getTeam()
	if (SERVER) then
		return self.team
	end

	return self:GetNWInt("team_id")
end

-- gets the player's faction
-- PLACEHOLDER FUNCTION
function player:getFaction()
	return NULL
end
function player:inFaction()
	return NULL
end