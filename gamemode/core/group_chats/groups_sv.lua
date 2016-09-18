fw.chat.addCMD({"/", "all", "occ"}, "Sends a message out of character to all players on the server", function(ply, msg)
	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[Global] ")

	local fac = fw.team.factions[ ply:getFaction() ]
	local fname = fac:getName()
	local fcolor = fac:getColor()

	local prefix = string.sub(fname, 1, 1)
	table.insert(textCache, fcolor)
	table.insert(textCache, '['..prefix..'] ')

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")
	table.insert(textCache, Color(255, 255, 255))

	table.insert(textCache, msg)

	fw.notif.chat(player.GetAll(), unpack(textCache))
end):addParam("message", "string")

fw.chat.addCMD({"admin", "a"}, "Sends a message as an admin", function(ply, msg)
	local textCache = {}
	table.insert(textCache, Color(255, 0, 0))
	table.insert(textCache, "[Admin To All]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(player.GetAll(), unpack(textCache))
end):addParam("message", "string"):restrictTo("admin")

fw.chat.addCMD({"fac", "faction", "team"}, "Sends a message to all players in your faction", function(ply, msg)
	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[Faction] ")

	local fac = fw.team.factions[ ply:getFaction() ]
	local fname = fac:getName()
	local fcolor = fac:getColor()

	local prefix = string.sub(fname, 1, 1)
	table.insert(textCache, fcolor)
	table.insert(textCache, '['..prefix..'] ')

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	local players = fw.team.getFactionPlayers(ply:getFaction())

	fw.notif.chat(players, unpack(textCache))
end):addParam("message", "string")

fw.chat.addCMD({"pm", "msg"}, "Sends a message to a player", function(ply, target, msg)
	local textCache = {}
	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[PM From ")

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick())

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(target, unpack(textCache))

	target.reply_to = ply

	local textCache = {}
	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[PM To ")

	table.insert(textCache, team.GetColor(target:Team()))
	table.insert(textCache, target:Nick())

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(ply, unpack(textCache))

	ply.reply_to = target

end):addParam("receiver", "player"):addParam("message", "string")

fw.chat.addCMD({"reply"}, "Send a pm back to your latest PM conversation", function(ply, msg)
	if (not IsValid(ply.reply_to)) then return end

	local textCache = {}
	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[PM From ")

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick())

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(ply.reply_to, unpack(textCache))

	local textCache = {}
	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "[PM To ")

	table.insert(textCache, team.GetColor(ply.reply_to:Team()))
	table.insert(textCache, ply.reply_to:Nick())

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(ply, unpack(textCache))
end):addParam("message", "string")

fw.chat.addCMD({"broadcast", "br"}, "Sends a message to your faction as the boss", function(ply, msg)
	local textCache = {}
	table.insert(textCache, Color(255, 69, 0))
	table.insert(textCache, "[Broadcast From Boss]: ")

	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	local players = fw.team.getFactionPlayers(ply:getFaction())

	fw.notif.chat(players, unpack(textCache))
end):addParam("message", "string"):restrictTo("t_boss")

fw.chat.addCMD({"yell", "y"}, "Sends a message to players in your direct vacinity", function(ply, msg)
	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	table.insert(textCache, Color(255, 255, 0))
	table.insert(textCache, "[Yell] ")

	local fac = fw.team.factions[ ply:getFaction() ]
	local fname = fac:getName()
	local fcolor = fac:getColor()

	local prefix = string.sub(fname, 1, 1)
	table.insert(textCache, fcolor)
	table.insert(textCache, '['..prefix..'] ')

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")
	table.insert(textCache, Color(255, 255, 255))

	table.insert(textCache, msg)

	local players = {}
	for k,v in pairs(player.findInSphere(ply:GetPos(), 560)) do
		if (not v:IsPlayer()) then continue end

		table.insert(players, v)
	end

	fw.notif.chat(players, unpack(textCache))
end):addParam("message", "string")

---
--- BEGIN GROUP CHATS AND VOICE COMMANDS
---

fw.chat.addCMD({"g", "group"}, "Sends a message to players in your registered chat groups", function(ply, msg)
	local g_table = {}
	local g_name = ""
	for k,v in pairs(fw.group.chats) do
		if (v[ply:Team()]) then
			g_table = v
			g_name = k

			break
		end
	end

	local players = {}
	for k,v in pairs(player.GetAll()) do
		if (g_table[v:Team()] and ply:getFaction() == v:getFaction()) then
			table.insert(players, v)
		end
	end

	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	table.insert(textCache, Color(0, 0, 0))
	table.insert(textCache, "["..g_name.."] ")

	local fac = fw.team.factions[ ply:getFaction() ]
	local fname = fac:getName()
	local fcolor = fac:getColor()

	local prefix = string.sub(fname, 1, 1)
	table.insert(textCache, fcolor)
	table.insert(textCache, '['..prefix..'] ')

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")
	table.insert(textCache, Color(255, 255, 255))

	table.insert(textCache, msg)

	fw.notif.chat(players, unpack(textCache))
end):addParam("message", "string")

fw.chat.addCMD({"radio", "r"}, "Toggles the player's group chat radio", function(ply)
	local inVoice = false
	for k,v in pairs(fw.group.voice) do
		if (v[ply:Team()]) then
			ply:SetNWBool("radio", not ply:GetNWBool("radio", false))
			inVoice = true

			break
		end
	end

	if (not inVoice) then
		ply:FWChatPrintError("you aren't in a valid voice group!")
		return
	end

	local status = ply:GetNWBool("radio") and "on" or "off"
	fw.notif.chat(ply, "voice radio toggled to "..status)
end)

--TODO: MOVE THIS TO CONFIG
local police_teams = {
	TEAM_POLICE, TEAM_POLICE_CHIEF
}
fw.chat.addCMD("911", "Sends a 911 prompt to all available police", function(ply, msg)
	ply:FWChatPrint(team.GetColor(ply:Team()), ply:Nick(), color_white, " -> ", Color(0, 0, 255), "[911]", color_white, ": ", msg)

	local players = {}
	for k,v in pairs(player.GetAll()) do
		if (table.HasValue(police_teams, v:Team())) then
			table.insert(players, v)
		end
	end

	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	local tag = ply:Team() == TEAM_DISPATCH and "[Dispatch]" or "[911]"

	table.insert(textCache, Color(0, 0, 255, 100))
	table.insert(textCache, "[911] ")
	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")
	table.insert(textCache, Color(255, 255, 255))
	table.insert(textCache, msg)

	fw.notif.chat(players, unpack(textCache))
end):addParam("message", "string")

fw.hook.Add("PlayerCanHearPlayersVoice", "RadioPlayerVoice", function(listener, talker)
	if (listener:GetNWBool("radio") and talker:GetNWBool("radio")) then
		for k,v in pairs(fw.group.voice) do
			if (v[talker:Team()] and v[listener:Team()]) then
				return true, false
			end
		end
	end

	--distance based voice chat
	if (listener:GetPos():DistToSqr(talker:GetPos()) <= 560 * 560) then return true, true end
end)
