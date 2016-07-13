fw.team.factions = {}

local faction_mt = {
	getName = function(self) return self.name end,
	getID = function(self) return self.index end,
	getStringID = function(self) return self.stringID end,
	getPlayers = function(self)
		local tbl = {}
		for k,v in pairs(player.GetAll()) do
			if v:getFaction() == self.index then
				tbl[#tbl + 1] = v 
			end
		end
	end,
}

-- fw.team.registerFaction
-- @param factionName:string
-- @param factionData:table 
-- @ret factionIndex:number
function fw.team.registerFaction(factionName, tbl)
	-- assert structure
	assert(tbl.stringID, 'faction.stringID must be defined')

	tbl.index = table.insert(fw.team.factions, tbl)
	tbl.name = factionName

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

-- fw.team.getFactionPlayers(factionID)
-- @param factionId:number - the faction to get the players of. nil for unaffiliated.
-- @ret players:table
function fw.team.getFactionPlayers(factionId)
	return ra.util.filter(player.GetAll(), function(ply)
		return ply:getFaction() == factionId
	end)
end

function fw.team.getBoss(factionId)
	if (not fw.team.factions[factionId]) then return "No Boss" end
	
	return fw.team.factions[factionId].boss or "No Boss"
end

local Player = FindMetaTable 'Player'

-- gets the player's faction
function Player:getFaction()
	return self:GetFWData().faction
end
function Player:inFaction()
	return self:GetFWData().faction ~= nil 
end