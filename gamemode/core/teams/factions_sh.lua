fw.team.factions = {}
local factionsList = fw.team.factions

if SERVER then
	if not ndoc.table.fwFactions then 
		ndoc.table.fwFactions = {}
	end
	concommand.Add("fw_faction_leave", function(ply)
		fw.team.removePlayerFromFaction(ply)
	end)
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
		return ndoc.table.fwFactions[self.index] or {}
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

	setmetatable(tbl, faction_mt)

	tbl.index = table.insert(fw.team.factions, tbl)
	tbl.name = factionName
	tbl.command = 'fw_joinfaction_' .. tbl.stringID

	if SERVER then
		concommand.Add(tbl.command, function(ply)
			local canjoin, message = fw.team.canJoinFaction(ply, tbl.index)

			if (not canjoin) then
				if (not message) then message = "You can't join this faction!" end
				
				ply:FWChatPrint(message)
				return
			end

			fw.team.addPlayerToFaction(ply, tbl.index)
		end)

		ndoc.table.fwFactions[tbl.index] = {
			money = 10000,
			boss = nil,
			inventory = {},
			agenda = nil
			-- inventory = {}, -- TODO: determine if inventory sholud exist at faction level
			-- all other data to come...
		}
	end

	return tbl.index -- return the faction id
end

function fw.team.canJoinFaction(ply, factionId)
	local players = #player.GetAll()

	local faction = factionsList[factionId]
	if not faction then return false, "No such faction" end

	local factionPlayers = #faction:getPlayers()
	local factionMeta = factionsList[factionId]

	if (factionPlayers / players > (factionMeta.fraction or (1.0 / #factionMeta))) then
		return true, "Faction already full!"
	end

	local canjoin, msg = hook.Call("PlayerCanJoinFaction", GAMEMODE, ply, faction)
	return canjoin ~= false, msg
end

-- fw.team.getFactionByID
-- returns the faction by it's numeric id
-- @param index:number
-- @ret faction:table
function fw.team.getFactionByID(factionId)
	return factionsList[factionId]
end

-- fw.team.getFactionByStringId(stringID)
-- @param stringID:string - the faction to get by it's string id
-- @ret faction:table - the meta data table for the faction
function fw.team.getFactionByStringID(stringID)
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
	return factionsList[self:getFaction()].boss
end

function Player:getFactionObj()
	return factionsList[self:getFaction()]
end