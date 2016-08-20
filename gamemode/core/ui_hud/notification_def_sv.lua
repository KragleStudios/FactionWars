fw.hook.Add('PlayerDeath', function(pl, inflictor, attacker)
	if pl == attacker then
		fw.hud.pushNotification(pl, 'LIFE CYCLE', 'You committed suicide')
		return
	end
	if IsValid(attacker) and attacker:IsPlayer() then
		local victimFaction = fw.team.factions[pl:getFaction()]
		local attackerFaction = fw.team.factions[attacker:getFaction()]
		if not attackerFaction or not victimFaction then return end
		fw.hud.pushNotification(attackerFaction:getPlayers(), 'FACTION', pl:Nick() .. ' killed by '..attackerFaction:getName())
	else
		fw.hud.pushNotification(pl, 'LIFE CYCLE', 'You died.')
	end
end)
