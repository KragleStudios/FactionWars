function team.GetPlayers(teamIndex)
	local t = fw.team.list[teamIndex]
	if (not t) then return {} end

	return t.players 
end
