fw.team.scores = fw.team.scores or {}
fw.team.stats  = fw.team.stats  or {frags = {}, deaths = {}}
if (SERVER) then
	util.AddNetworkString("team_frags")
	util.AddNetworkString("team_deaths")
end

function team.GetName(teamIndex)
	local t = fw.team.list[teamIndex]
	if (!t) then return "" end
	
	return t.job
end

function team.GetPlayers(teamIndex)
	local t = fw.team.list[teamIndex]
	if (!t) then return {} end

	return t.players 
end

function team.GetSpawnPoints(teamIndex)
	if (SERVER) then
		local t = fw.team.list[teamIndex]
		if (!t) then return end
		
		local sp = t.stringID
		if (!sp) then return end
		
		return fw.team.spawns[sp] or {}
	else
		//NETWORK SPAWN POINTS BTW SERV AND CLIENT
	end
end

//This is a buggy work around and does NOT produce accurate results 100% of the time,
//as it depends on the player's team and the custom function of the job
function team.Joinable(teamIndex)
	local t = fw.team.list[teamIndex]
	if (!t) then return end
	
	if (self.GetPlayers() == t.max) then return false end
	if (t.factionOnly) then return false end

	return true
end

function team.GetAllTeams()
	return fw.team.list
end

function team.NumPlayers(teamIndex)
	return #team.GetPlayers(teamIndex)
end

function team.TotalFrags(teamIndex)
	return fw.team.stats.frags[teamIndex]
end

function team.TotalDeaths(teamIndex)
	return fw.team.stats.deaths[teamIndex]
end

function team.GetScore(teamIndex)
	return fw.team.scores[teamIndex] or 0
end

function team.SetScore(teamIndex, score)	
	fw.team.scores[teamIndex] = score

	return score
end

function team.AddScore(teamIndex, amt)	
	local sc = fw.team.scores[teamIndex]
	if (!sc) then sc = 0 end
	
	sc = sc + amt

	fw.team.scores[teamIndex] = sc

	return sc
end

local Player = FindMetaTable("Player")
function Player:Team()
	return self:getTeam()
end

function Player:SetTeam(teamIndex)
	fw.team.setPlayer(self, teamIndex)
end

if (SERVER) then
	hook.Add("PlayerDeath", "UpdateTeamStats", function(vic, inf, att)
		if (IsValid(vic) and IsValid(att) and vic:IsPlayer() and att:IsPlayer()) then
			net.Start("team_deaths")
				net.WriteInt(vic:getTeam(), 32)
				net.WriteInt(att:getTeam(), 32)
			net.Broadcast()

			local att_team = att:getTeam()
			local vic_team = vic:getTeam()

			if (!fw.team.stats.frags[att_team]) then
				fw.team.stats.frags[att_team] = 1
			else
				fw.team.stats.frags[att_team] = fw.team.stats.frags[att_team] + 1
			end
			if (!fw.team.stats.deaths[vic_team]) then
				fw.team.stats.deaths[vic_team] = 1
			else
				fw.team.stats.deaths[vic_team] = fw.team.stats.deaths[vic_team] + 1
			end
		end
	end)
else
	net.Receive("team_deaths", function()
		local vic_team = net.ReadInt(32)
		local att_team = net.ReadInt(32)

		if (!fw.team.stats.frags[att_team]) then
			fw.team.stats.frags[att_team] = 1
		else
			fw.team.stats.frags[att_team] = fw.team.stats.frags[att_team] + 1
		end
		if (!fw.team.stats.deaths[vic_team]) then
			fw.team.stats.deaths[vic_team] = 1
		else
			fw.team.stats.deaths[vic_team] = fw.team.stats.deaths[vic_team] + 1
		end
	end)
end
