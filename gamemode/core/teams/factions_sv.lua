function fw.team.addPlayerToFaction(ply, factionId)
	local t = fw.team.list[ply:Team()]
	local f = fw.team.factions[factionId]
	if not f then return end

	--for player counts!
	fw.team.demotePlayer(ply)
	ply:FWChatPrint("You have been set to Civilian!")
	
	hook.Run("PlayerLeftFaction", ply, ply:getFaction())
	ply:GetFWData().faction = factionId
	hook.Run('PlayerJoinedFaction', ply, factionId)
end

function fw.team.removePlayerFromFaction(ply)
	if not ply:inFaction() or ply:getFaction() == FACTION_DEFAULT then return end
	fw.team.addPlayerToFaction(ply, FACTION_DEFAULT)
end

function fw.team.setFactionBoss(factionId, ply)
	ndoc.table.fwFactions[factionId].boss = ply
end

function fw.team.removeFactionBoss(factionId)
	fw.team.setFactionBoss(factionId, nil)
end
