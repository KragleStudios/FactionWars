function fw.team.addPlayerToFaction(ply, factionId)
	local t = fw.team.list[ply:Team()]
	local f = fw.team.factions[factionId]
	if not f then return end

	-- if no team or the new faction doesn't have access to the team
	if not t or (ply:Team() ~= TEAM_CITIZEN and t.factions ~= nil and not table.HasValue(t.factions)) then
		ply:FWChatPrint("You have been set to citizen since your new faction doesn't have access to your old job!")
		fw.team.demotePlayer(ply)
	end
	
	hook.Run("PlayerLeftFaction", ply, ply:getFaction())
	ply:GetFWData().faction = factionId
	hook.Run('PlayerJoinedFaction', ply, factionId)
end

function fw.team.removePlayerFromFaction(ply)
	if not ply:inFaction() or ply:getFaction() == FACTION_DEFAULT then return end
	fw.team.addPlayerToFaction(ply, FACTION_DEFAULT)
end

function fw.team.setFactionBoss(factionId, ply)
	print(factionId, ply)
	ndoc.table.fwFactions[factionId].boss = ply
end

function fw.team.removeFactionBoss(factionId)
	fw.team.setFactionBoss(factionId, nil)
end
