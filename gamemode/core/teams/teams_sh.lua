fw.team.list = fw.team.list or {}
fw.team.factionAgendas = fw.team.factionAgendas or {}

-- meta table for a team
local team_mt = {
	getName = function(self)
		return self.name
	end,
	getStringID = function(self)
		return self.stringID
	end,
	getModels = function(self)
		return self.models
	end,
	getWeapons = function(self)
		return self.weapons 
	end,
	getID = function(self)
		return self.index
	end,
	getPlayers = function(self)
		return team.GetPlayers(self.index) 
	end,
	addPlayer = function(self, ply, pref_mdoel, forced)
		fw.team.playerChangeTeam(ply, self.index, pref_model, forced)
	end
}
team_mt.__index = team_mt

-- fw.team.register - Registers a new team to the system
-- @param name:string - the name of the team, ie: "Civilian", "Police Officer"
-- @param tbl:tbl - the table data of the new team
-- @ret a meta object of the new team assigned to the variable in the configuration
function fw.team.register(name, tbl) 
	-- DO CHECKS FOR TEAM CORRECT - TODO: finish
	assert(tbl.model or tbl.models, "must provide model or models")
	assert(tbl.stringID, "must provide stringID")
	assert(tbl.salary, "a salary must be provided!")

	local index = table.insert(fw.team.list, tbl)

	-- setup required properties
	tbl.name = name
	tbl.index = index
	tbl.color = tbl.color or Color(0, 155, 0)
	tbl.players = {}
	tbl.weapons = tbl.weapons or {}
	tbl.models = tbl.models or {tbl.model}
	tbl.election = tbl.election or false

	tbl.command = 'fw_job_' .. tbl.stringID

	-- set meta table and create the team
	setmetatable(tbl, team_mt)
	team.SetUp(tbl.index, name, tbl.color)

	--reset team table with new data
	fw.team.list[index] = tbl

	if SERVER then
		-- TODO: thelastpenguin: add a chat command for this
		concommand.Add(tbl.command, function(pl, cmd, args)
			if args[1] then -- preferred model is the first argument
				fw.team.setPreferredModel(tbl.index, pl, args[1])
			end

			tbl:addPlayer(pl, args[1])
		end)
	end

	return tbl.index
end

-- getByIndex(index)
-- @param index:number - the index of the team to get
-- @ret team object
function fw.team.getByIndex(index)
	return fw.team.list[index]
end

-- canChangeTeam - tells you if a player can join targ_team 
-- @param ply:player object - the player switching teams
-- @param targ_team:int - the index of the team in the table
-- @param optional forced:bool should we ignore canjoin conditions
-- @ret nothing
function fw.team.canChangeTo(ply, targ_team, forced)
	if forced then return true, nil end

	local canjoin, message = hook.Call("CanPlayerJoinTeam", GAMEMODE, ply, targ_team)

	return canjoin ~= false, message 
end

-- fw.team.getByStringId - Gets a team's data by the string used, "civilian", "police_officer"
-- @param team_textID:string - the string_id found in the team configuration
-- @ret the table team
function fw.team.getByStringID(id)
	for k,v in ipairs(fw.team.list) do -- todo: optimize this
		if (v.stringID == id) then
			return v
		end
	end

	error("FAILED TO FIND TEAM")
end

local Player = FindMetaTable("Player")

function Player:getPrefModel()
	return ply:GetFWData().pref_model
end

--
-- HOOKS
--  
-- handles the ability of whether or not a player can join a team
fw.hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	local t = fw.team.list[targ_team]
	if (not t) then 
		return false 
	end
	
	-- enforce t.max players
	if t.max and t.max != 0 then
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
	if (t.faction and not ply:inFaction() and ply:getFaction() ~= FACTION_DEFAULT) then 
		return false
	end 
	-- notify incorrect faction
	if (t.faction) then
		if istable(t.faction) and not table.HasValue(t.faction, ply:getFaction()) then
			return false
		elseif (t.faction ~= ply:getFaction()) then
			return false
		end
	end

	local canjoin = t.canJoin
	if canjoin then
		if (istable(canjoin)) then
			return table.HasValue(canjoin, ply:Team())
		else
			return canjoin(t, ply) ~= false
		end
	end
end)