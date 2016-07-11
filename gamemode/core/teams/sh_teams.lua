fw.team.list = fw.team.list or {}

-- fw.team.register - Registers a new team to the system
-- @param name:string - the name of the team, ie: "Civilian", "Police Officer"
-- @param tbl:tbl - the table data of the new team
-- @ret a meta object of the new team assigned to the variable in the configuration
function fw.team.register(name, tbl) -- DO CHECKS FOR TEAM CORRECT
	tbl.players = {}
	tbl.job = name

	assert(tbl.model or tbl.models, "must provide model or models")
	assert(tbl.stringID, "must provide stringID")

	local index = table.insert(fw.team.list, tbl)
	tbl.ind = index
	tbl.players = {}
	tbl.weapons = tbl.weapons or {}
	tbl.models = tbl.models or {tbl.model}

	fw.team.list[index].ind = index
	fw.team.list[index].players = {}

	local team_meta = {
		getStringID = function() 
				return tbl.stringID or name
			end,
		getModels = function()
				return tbl.models
			end,
		getWeapons = function()
				return tbl.weapons
			end,
		getID = function()
				return index
			end,
		getPlayers = function()
				return tbl.players
			end,
		getInfo = function()
				return tbl
			end,
	}

	team_meta.__index = team_meta
	setmetatable(tbl, team_meta)

	return tbl
end

concommand.Add("test", function()
	PrintTable(TEAM_CIVILIAN:getPlayers())
end)

-- fw.team.getByStringId - Gets a team's data by the string used, "civilian", "police_officer"
-- @param team_textID:string - the string_id found in the team configuration
-- @ret the table team
fw.team.getByStringID = ra.fn.memoize(function(team_textID)
	for k,v in ipairs(fw.team.list) do -- todo: optimize this
		if (v.stringID == team_textID) then
			return v
		end
	end

	error("FAILED TO FIND TEAM")
end)

-- fw.team.demotePlayer - force demotes a player back to the citizen team
-- @param py:player - the player to demote
-- @ret nothing
function fw.team.demotePlayer(ply)
	if (!IsValid(ply)) then return end
	
	playerChangeTeam(ply, TEAM_CIVILIAN:getID(), table.Random(TEAM_CIVILIAN:getModels()))
end

-- fw.team.addPlayerToTeam - sets a player to a job, regardless of restrictions
-- @param ply:player - the player to set the job on
-- @param team_id_num:integer - the index value in the master team table, found by TEAM_*:getID()
-- @ret nothing
function fw.team.addPlayerToTeam(ply, team_id_num)
	if (!IsValid(ply) or !team_textID) then return end
	
	local team = fw.team.list[team_textID]
	if (!team) then return end
	
	playerChangeTeam(ply, team_id_num, nil, true)
end

-- handles the ability of whether or not a player can join a team
fw.hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	if (!targ_team or !ply:Alive()) then
		-- NOTIFY NO TARG_TEAM
		return false
	end
	
	local t = fw.team.list[targ_team]
	if (!t) then 
		-- NOTIFY TEAM NOT FOUND
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

	-- SUPPORT FOR FACTION ONLY JOBS
	if ((t.factionOnly and !t.faction) and ply:getFaction() == NULL) then 
		return false
	end 
	-- notify incorrect faction
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
		-- net_writeValue NOTIFY TARG_TEAM NOT FOUND
		return
	end

	local canjoin = hook.Call("CanPlayerJoinTeam", GAMEMODE, ply, targ_team)
	if (!forced and !canjoin) then
		-- NOTIFY CAN'T JOIN TEAM
		return false 
	end

	local t = fw.team.list[targ_team]

	-- find a good pref_model
	if not pref_model then
		if ply:GetFWData().preferred_models then
			pref_model = ply:GetFWData().preferred_models[t.stringID] or table.Random(t.models)
		end
	end

	-- insert the players
	t.players = t.players or {}
	table.insert(fw.team.list[targ_team].players, ply)

	local last_team = fw.team.list[ply:getTeam()]
	if (!last_team) then return end
	table.RemoveByValue(fw.team.list[ply:getTeam()].players, ply)

	if (SERVER) then
		ply:GetFWData().last_team = ply:getTeam() 
		ply:GetFWData().team = targ_team 
		ply:GetFWData().pref_model = pref_model
		if not ply:GetFWData().preferred_models then
			ply:GetFWData().preferred_models = {}
		end
		ply:GetFWData().preferred_models[t.stringID] = pref_model
		ply:GetFWData().pref_model = pref_model

		-- NOTIFY PLAYER CHANGED TEAM

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

function player:getPrefModel()
	return ply:GetFWData().pref_model
end

-- gets the player's index team id
function player:getTeam()
	return self:GetFWData().team
end

-- gets the player's faction
-- PLACEHOLDER FUNCTION
function player:getFaction()
	return self:GetFWData().faction
end
function player:inFaction()
	return self:GetFWData().faction ~= nil 
end