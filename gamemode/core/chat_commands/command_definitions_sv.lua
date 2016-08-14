--basic help command
fw.chat.addCMD("help", "Prints a help log to your screen", function(pl)
	local function formatParameters(param, ...)
		if not param then return end
		return '<' .. param.type .. ':' .. param.name .. '>', formatParameters(...)
	end

	pl:FWChatPrint("Please check your console for chat command help")

	local alreadySeen = {}
	for name, command in SortedPairs(fw.chat.cmds) do
		if not alreadySeen[command] then
			alreadySeen[command] = true
			local color = command.permCheck(pl) and Color(0, 255, 0) or Color(255, 0, 0)
			pl:FWConPrint(color, table.concat(command.aliases, ' or '), color_white, ' - ', command.helptext)
			local paramHelp = table.concat({formatParameters(unpack(command.params))}, ' ')
			if string.len(paramHelp) > 0 then
				pl:FWConPrint(color_white, '\t', paramHelp)
			end
		end
	end
end)

fw.chat.addCMD("vote", "Makes a vote available to everyone", function(ply, desc)
	fw.vote.createNew(ply:Nick().."'s vote", desc, player.GetAll(),
		function(decision, vote, results)

			decision = decision and vote.yesText or vote.noText

			fw.notif.chatPrint(player.GetAll(), color_black, "[Votes]: ", color_white, "'"..decision.. "' won in ", ply:Nick(), "'s vote, with ".. results.yesVotes .." Yes votes, and ".. results.noVotes .." No votes!")

		end, "Yes", "No", 15)
end):addParam("description", "string")

fw.chat.addCMD("dropmoney", "Drops some money in front of you", function(ply, money)
	money = math.abs(money)
	if ply:canAfford(money) then
		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
			filter = function( ent ) if ent ~= ply then return true end end
		})

		ply:addMoney(-money)

		local ent = ents.Create("fw_money")
		ent:SetValue(money)
		ent:SetPos(tr.HitPos)
		ent:Spawn()
	end
end):addParam("money", "number")

fw.chat.addCMD("drop", "Drop your weapon", function(ply)
	if IsValid(ply:GetActiveWeapon()) and not fw.config.dropBlacklist[ply:GetActiveWeapon():GetClass()] then
		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
			filter = function(ent) if ent ~= ply then return true end end
		})

		local ent = ents.Create("fw_gun")
		ent:setWeapon(ply)
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		ply:GetActiveWeapon():Remove()
	else
		ply:FWChatPrint("You cannot drop this weapon.")
	end
end)

local quotelist = {
	['thelastpenguin'] = {
		"takes forever to download, especially when you have downloads off",
		"ask him if he's had an anol probe done recently, cuz dem errors, are coming out of his a**",
		"im confused as to why that's confusing...",
		"but rly mikey get lastest version of faction wars",
		"he is the definition of a human fart. If only he'd just stink off and evaporate ",
	},
	['Spai'] = {
		"Editing DarkRP, anyone can do it, but it is all about how you edit it, that is what not everyone can do correctly. - Commander Grox",
	},
	['Mikey Howell'] = {
		"do you realise you're saying lastest",
		"omg I make all my commits on the website too!",
		"i just made french toast. call me daddy",
	},
	['crazyscouter'] = {
		"Use effects.halo.Add()",
		"Guys I just realized I've been using the women's restroom the entire time I've been at this restaraunt",
		"It's the kragle that keeps us together"
	},
	['meharryp'] = {
		"memes",
		"yeah go fuck a moose and drink your maple syrup"
	},
	['Google'] = {
		"single quotes are bad because they are alone and they will be bullied"
	},
	['aStonedPenguin'] = {
		"guys i make all my commits from the github website",
		"i just wanted ot be here"
	}
}
fw.chat.addCMD("quote", "", function(ply)
	local rAuthor, name = table.Random(quotelist)
	local rQuote = table.Random(rAuthor)

	fw.notif.chatPrint(player.GetAll(), name, ': ', rQuote)
end)

fw.chat.addCMD("define", "Defines a given string", function(ply, searc)
	http.Fetch("http://api.urbandictionary.com/v0/define?term="..searc, function(body)
		local tbl = util.JSONToTable(body);

		local def = tbl["list"][1];

		if (!def) then
			fw.notif.chatPrint(player.GetAll(), Color(0, 0, 0), "[Bot] ", Color(255, 255, 255), "No definition found, sorry!");
			return;
		end

		fw.notif.chatPrint(player.GetAll(), Color(0, 0, 0), "[Bot] ", Color(255, 255, 255), "Definition of "..searc..": "..def["definition"])

	end, function(errr)

	end)
end):addParam("string_to_search", "string")

fw.chat.addCMD("@", "Sends a message to online admins", function(ply, msg)
	local header = ply:IsAdmin() and "[Admin Chat]" or "[Admin Request]"

	local plys = {}
	for k,v in pairs(player.GetAll()) do
		if (v:IsAdmin()) then
			table.insert(plys, v)
		end
	end

	fw.notif.chatPrint(plys, Color(255, 25, 25), header," ", team.GetColor(ply:Team()), ply:Nick(), ": ", Color(255, 255, 255), msg)
end):addParam("message", "string")
