function fw.team.addPlayerToFaction(ply, factionId)
	ply:GetFWData().faction = factionId
	hook.Run('PlayerJoinedFaction', factionId)
end

function fw.team.removePlayerFromFaction(ply)
	if (ply:inFaction()) then return end
	
	local t = fw.team.list[ply:Team()]
	if t ~= nil and (t.faction ~= nil or team.factionOnly) then
		-- if they are removed from the faction they must loose their job if it is limited to their faction
		fw.team.demotePlayer(ply)
	end

	local oldFaction = ply:getFaction()
	fw.team.addPlayerToFaction(ply, FACTION_DEFAULT)

	hook.Run('PlayerLeftFaction', oldFaction)

	fw.team.playerChangeTeam(ply, TEAM_CITIZEN:getID(), true)
end

function fw.team.setFactionBoss(factionId, ply)
	fw.team.getFactionByID(factionId):getNWData().boss = ply
end

function fw.team.removeFactionBoss(factionId)
	fw.team.setFactionBoss(factionId, nil)
end
