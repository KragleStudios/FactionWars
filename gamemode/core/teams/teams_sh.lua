fw.team.list = fw.team.list or {}

-- meta table for a team
local team_mt = {
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
	addPlayer = function(self, pref_mdoel, forced)
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

	local index = table.insert(fw.team.list, tbl)

	-- setup required properties
	tbl.name = name
	tbl.index = index
	tbl.color = tbl.color or Color(0, 155, 0)
	tbl.players = {}
	tbl.weapons = tbl.weapons or {}
	tbl.models = tbl.models or {tbl.model}

	tbl.command = 'fw_job_' .. tbl.stringID

	-- set meta table and create the team
	setmetatable(tbl, team_mt)
	team.SetUp(tbl.index, name, tbl.color)

	if SERVER then
		concommand.Add('fw_team_' .. tbl.command, function(pl, cmd, args)
			if args[1] then -- preferred model is the first argument
				fw.team.setPreferredModel(tbl.index, pl, args[1])
			end

			self:addPlayer(nil, nil)
		end)
	end

	return tbl
end

concommand.Add("test", function()
	PrintTable(TEAM_CIVILIAN:getPlayers())
end)


function fw.team.getByIndex(index)
	return fw.team.list[index]
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



-- handles the ability of whether or not a player can join a team
fw.hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	local t = fw.team.list[targ_team]
	if (not t) then 
		return false 
	end
	
	
	-- enforce t.max players
	if t.max and #t:getPlayers() > t.max then return false end

	-- can't join a team you're already on
	if (ply:Team() == targ_team) then return false end

	-- SUPPORT FOR FACTION ONLY JOBS
	if ((t.factionOnly and !t.faction) and ply:getFaction() == NULL) then 
		return false
	end 
	-- notify incorrect faction
	if ((t.factionOnly and t.faction) and (ply:getFaction() != t.faction)) then
		-- TODO: notify them why they can't join
		return false
	end

	local canjoin = t.canJoin
	if canjoin then
		if (istable(canjoin)) then
			for k,v in ipairs(canjoin) do
				if (ply:Team() == v) then
					return true
				end
			end
		else
			return canjoin(t, ply)
		end
	else
		return true
	end
end)


if (SERVER) then
	-- TODO: this should be a concommand.
	net.Receive("playerChangeTeam", function(l, client)
		local team_id = net.ReadInt(32)
		local model = net.ReadString()

		fw.team.playerChangeTeam(client, team_id, model)
	end)
end


local Player = FindMetaTable("Player")

function Player:getPrefModel()
	return ply:GetFWData().pref_model
end