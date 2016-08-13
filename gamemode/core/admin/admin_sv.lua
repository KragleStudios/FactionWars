fw.admin.cmds = {}
fw.admin.cmds.player = {}
fw.admin.cmds.server = {}

fw.admin.mutes = {}
fw.admin.gags = {}

local function AddAdminCommand(obj, type)
	obj = obj:restrictTo("admin")
	table.insert(fw.admin.cmds[type], obj)
end

local function PermissionCheck(ply, superadmin)
	if IsValid(ply) and not (superadmin and ply:IsSuperAdmin() or ply:IsAdmin()) then return false end
	return true
end

fw.hook.Add("PlayerSay", "AdminMuteCheck", function(ply, text)
	if fw.admin.mutes[ply] then
		ply:FWChatPrint("You have been chat muted and cannot speak using text chat.")
		return ""
	end
end)

fw.hook.Add("PlayerCanHearPlayersVoice", "AdminGagCheck", function(listener, talker)
	if fw.admin.gags[talker] then
		return false
	end
end)

AddAdminCommand(fw.chat.addCMD("slay", "Kill a player", function(ply, target)
	target:Kill()
	ply:FWChatPrint("You have slain " .. target:Nick())
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("sslay", "Kill a player silently", function(ply, target)
	target:KillSilent()
	ply:FWChatPrint("You have slain " .. target:Nick())
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("kick", "Kick a player", function(ply, target, reason)
	target:Kick(reason)
	ply:FWChatPrint("You kicked " .. target:Nick() .. " for " .. reason)
end):addParam("target", "player"):addParam("reason", "string"), "player")

AddAdminCommand(fw.chat.addCMD("ban", "Ban a player", function(ply, target, reason, time)
	target:Ban(time)
	target:Kick("BANNED: " .. reason .. "\nThis ban will expire in " .. time .. " minuites")
	ply:FWChatPrint("You banned " .. target:Nick() .. " for " .. reason .. " for " .. time .. " minuites")
end):addParam("target", "player"):addParam("reason", "string"):addParam("time", "number"), "player", "Ban")

AddAdminCommand(fw.chat.addCMD("unban", "Unban a steamid", function(ply, target)
	RunConsoleCommand("removeid", target)
	ply:FWChatPrint("You kicked " .. target:Nick() .. " for " .. reason .. " for " .. time .. " minuites")
end):addParam("target", "string"), "player")

AddAdminCommand(fw.chat.addCMD("mute", "Prevent a player from talking in chat", function(ply, target)
	fw.admin.mutes[target] = true
	ply:FWChatPrint("You have muted " .. target:Nick())
	target:FWChatPrint("You have been muted by an admin. You may no longer talk using text chat.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("unmute", "Unmutes a player", function(ply, target)
	fw.admin.mutes[target] = false
	ply:FWChatPrint("You have unmuted " .. target:Nick())
	target:FWChatPrint("You have been unmuted by an admin. You may now talk using text chat.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("gag", "Prevent a player from talking in voice", function(ply, target)
	fw.admin.gags[target] = true
	ply:FWChatPrint("You have gagged " .. target:Nick())
	target:FWChatPrint("You have been gagged by an admin. You may no longer talk using voice chat.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("ungag", "Remove a gag from a player", function(ply, target)
	fw.admin.gags[target] = false
	ply:FWChatPrint("You have ungagged " .. target:Nick())
	target:FWChatPrint("You have been ungagged by an admin. You may now talk using voice chat.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("freeze", "Prevent a player from making any action", function(ply, target)
    target:Freeze(true)
	ply:FWChatPrint("You are frozen " .. target:Nick())
	target:FWChatPrint("You have been frozen by an admin. You may not make any actions.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("unfreeze", "Unfreeze a frozen player", function(ply, target)
    target:Freeze(false)
	ply:FWChatPrint("You are now unfrozen " .. target:Nick())
	target:FWChatPrint("You have been unfrozen by an admin. You may now make action.")
end):addParam("target", "player"), "player")

AddAdminCommand(fw.chat.addCMD("setjob", "Set a players job", function(ply, target, newTeam)
	local teamID
	local succ = pcall(function() teamID = fw.team.getByStringID(newTeam) end)

	if succ and teamID then
		fw.team.playerChangeTeam(target, teamID.index, true)
		ply:FWChatPrint("You have set the job of " .. target:Nick() .. " to " .. teamID.name)
		target:FWChatPrint("You have had your job set to " .. teamID.name .. " by an admin")
	else
		ply:FWChatPrint("Could not find a job by that StringID!")
	end
end):addParam("target", "player"):addParam("job", "string"), "player")

AddAdminCommand(fw.chat.addCMD("setfaction", "Set a players faction", function(ply, target, newTeam)
	local teamID
	local succ = pcall(function() teamID = fw.team.getFactionByStringID(newTeam) end)

	if succ and teamID then
		fw.team.addPlayerToFaction(target, teamID.index)
		ply:FWChatPrint("You have set the faction of " .. target:Nick() .. " to " .. teamID.name)
		target:FWChatPrint("You have had your team set to " .. teamID.name .. " by an admin")
	else
		ply:FWChatPrint("Could not find a faction by that StringID!")
	end
end):addParam("target", "player"):addParam("faction", "string"), "player")

AddAdminCommand(fw.chat.addCMD("cvar", "Set a cvar on the server", function(ply, stringCvar, val) -- Superadmins only, this is a command for trusted users.
	RunConsoleCommand(stringCvar, val)
end):addParam("cvar", "string"):addParam("value", "string"), "server")
