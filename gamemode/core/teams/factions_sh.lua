fw.team.factions = {}

local factionsList = fw.team.factions

if SERVER then
	ndoc.table.fwFactions = {}
end

local faction_mt = {
	getName = function(self) return self.name end,
	getID = function(self) return self.index end,
	getStringID = function(self) return self.stringID end,
	getPlayers = function(self)
		return ra.util.filter(player.GetAll(), function(ply)
			return ply:getFaction() == self.index
		end)
	end,
	getColor = function(self)
		return self
	end,
	getNWData = function(self)
		return ndoc.fwFactions[self.index] or {}
	end,
	getBoss = function(self)
		return self:getNWData().boss
	end,
}
faction_mt.__index = faction_mt

-- fw.team.registerFaction
-- @param factionName:string
-- @param factionData:table 
-- @ret factionIndex:number
function fw.team.registerFaction(factionName, tbl)
	-- assert structure
	assert(tbl.stringID, 'faction.stringID must be defined')

	tbl.index = table.insert(fw.team.factions, tbl)
	tbl.name = factionName
	tbl.command = 'fw_joinfaction_' .. tbl.stringID

	if SERVER then
		ndoc.table.fwFactions[tbl.index] = {
			money = 10000,
			boss = nil,
			-- all other data to come...
		}
		-- boss = nil
		-- money = nil

		concommand.Add(tbl.command, function(ply)
			if not IsValid(ply) then return end 

			fw.team.addPlayerToFaction(ply, tbl.index)
		end)
	end

	setmetatable(tbl, faction_mt)

	return tbl.index -- return the faction id
end

-- fw.team.getFactionByID
-- returns the faction by it's numeric id
-- @param index:number
-- @ret faction:table
function fw.team.getFactionByID(factionId)
	return fw.team.factions[factionId]
end

-- fw.team.getFactionByStringId(stringID)
-- @param stringID:string - the faction to get by it's string id
-- @ret faction:table - the meta data table for the faction
function fw.team.getFactionByStringId(stringID)
	for k,v in ipairs(fw.team.factions) do
		if v.stringID == stringID then
			return v
		end
	end
end

function fw.team.getBoss(factionId)
	return factionsList[factionId]:getBoss()
end

-- fw.team.getFactionPlayers(factionID)
-- @param factionId:number - the faction to get the players of. nil for unaffiliated.
-- @ret players:table
function fw.team.getFactionPlayers(factionId)
	if not factionId then
		return player.GetAll()
	end
	return factionsList[factionId]:getPlayers()
end

local Player = FindMetaTable 'Player'

-- gets the player's faction
function Player:getFaction()
	return self:GetFWData().faction
end

function Player:inFaction()
	return self:GetFWData().faction ~= nil 
end

function Player:isFactionBoss()
	return self:getFactionBoss() == self
end

function Player:getFactionBoss()
	return self:inFaction() and fw.team.factions[self:getFaction()].boss or NULL
end