function fw.team.addPlayerToFaction(ply, factionId)
	local t = fw.team.list[ply:Team()]
	if t and (t.faction ~= nil) then
		if (istable(t.faction) and not table.HasValue(t.faction, TEAM_DEFAULT)) then 
			fw.team.demotePlayer(ply)
		elseif (t.faction ~= TEAM_DEFAULT) then
			fw.team.demotePlayer(ply)
		end
	end

	local oldFaction = ply:getFaction()

	hook.Run("PlayerLeftFaction", ply, oldFaction)

	ply:GetFWData().faction = factionId
	hook.Run('PlayerJoinedFaction', ply, factionId)
end

function fw.team.removePlayerFromFaction(ply)
	if not ply:inFaction() then return end
	
	local t = fw.team.list[ply:Team()]
	if t and (t.faction ~= nil) then
		if (istable(t.faction) and not table.HasValue(t.faction, TEAM_DEFAULT)) then 
			fw.team.demotePlayer(ply) 
		elseif (t.faction ~= TEAM_DEFAULT) then
			fw.team.demotePlayer(ply)
		end
	end

	local oldFaction = ply:getFaction()
	
	fw.team.addPlayerToFaction(ply, FACTION_DEFAULT)
	
	hook.Run('PlayerLeftFaction', ply, oldFaction)
end

function fw.team.setFactionBoss(factionId, ply)
	print(factionId, ply)
	ndoc.table.fwFactions[factionId].boss = ply
end

function fw.team.removeFactionBoss(factionId)
	fw.team.setFactionBoss(factionId, nil)
end
