function team.GetPlayers(teamIndex)
	local t = fw.team.list[teamIndex]
	if (!t) then return {} end

	return t.players 
end
