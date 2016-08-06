fw.chat.cmds = {}
fw.chat.help = {}
fw.chat.argTypes = {}
fw.chat.permissions = {
	['admin'] = function(pl) return pl:IsAdmin() end,
	['superadmin'] = function(pl) return pl:IsSuperAdmin() end,
	['boss'] = function(pl) return pl:isFactionBoss() end,
	['faction'] = function(pl) return pl:getFaction() ~= FACTION_DEFAULT end
}

local cmd_mt = {}
cmd_mt.__index = cmd_mt
function cmd_mt:ctor(aliases, helptext, callback)
	if type(aliases) == 'string' then
		aliases = {aliases}
	end

	self.aliases = aliases
	self.helptext = helptext
	self.params = {}
	self.permCheck = function() return true end
	self.callback = callback

	concommand.Add('fw_' .. aliases[1], function(pl, cmd, args)
		fw.chat.runCommand(self, args)
	end)

	for k, alias in ipairs(self.aliases) do
		fw.chat.cmds[alias] = self
	end

	return self
end

function cmd_mt:addParam(name, type)
	if not fw.chat.argTypes[type] then
		error("invalid argument type " .. tostring(type))
	end

	table.insert(self.params, {
		name = name,
		type = type
	})
	return self
end

function cmd_mt:restrictTo(func)
	if type(func) == 'string' then
		func = fw.chat.permissions[func]
	end
	if not func then error("expected a valid permission id or a permission function") end

	local oldFunc = self.permCheck
	self.permCheck = function(pl)
		return func(pl) and oldFunc(pl)
	end
	return self
end


-- PARSE A PLAYER ARGUMENT
fw.chat.argTypes['player'] = function(arguent, player)
	if argument == '^' then
		if IsValid(player) then
			return player
		end
		return nil, "you cant reference yourself when running command from server"
	end

	if argument:find('STEAM_') then
		for k,v in pairs(player.GetAll()) do
			if v:SteamID() == argument then
				return v
			end
		end
	end

	argument = argument:lower()

	local found = nil
	for k,v in pairs(player.GetAll()) do
		if v:Name() == argument then return v end
		if v:Name():lower():find(argument) then
			if found then return nil, 'two players matched substring, give a more exact name' end
			found = v
		end
	end
	if found then return found end
	return nil, 'no player found'
end

-- PARSE A STRING ARGUENT
fw.chat.argTypes['string'] = function(argument) return argument end
fw.chat.argTypes['number'] = function(argument)
	local num = tonumber(argument)
	if num == nil then return nil, 'malformatted number' end
	return num
end
fw.chat.argTypes['bool'] = function(argument)
	if arguent[1] == 'y' or argument[1] == 't' then return true end
	return false
end
fw.chat.argTypes['money'] = function(argument)
	if string.sub(argument, 1, 1) == '$' then
		return fw.chat.argTypes['money'](string.sub(argument, 2))
	end
	return fw.chat.argTypes['number'](argument)
end



--
-- ADD COMMAND
--
function fw.chat.addCMD(...)
	return setmetatable({}, cmd_mt):ctor(...)
end

local quotes = {
	['\''] = true,
	['\"'] = true
}
function fw.chat.parseLine(line)
	local function skipWhiteSpace(index)
		return string.find(line, '%S', index)
	end

	local function findNextSpace(index)
		return string.find(line, '%s', index)
	end

	local function findClosingQuote(index, type)
		return string.find(line, type, index)
	end

	local parts = {}

	local index = 1
	while index ~= nil do
		index = skipWhiteSpace(index)
		if not index then break end

		local cur = string.sub(line, index, index)
		if quotes[cur] then
			local closer = findClosingQuote(index + 1, cur)
			local quotedString = string.sub(line, index + 1, closer and closer - 1 or nil)
			table.insert(parts, quotedString)
			if not closer then break end
			index = closer
		else
			local nextSpace = findNextSpace(index)
			local word = string.sub(line, index, nextSpace and nextSpace - 1 or nil)
			table.insert(parts, word)
			if not nextSpace then break end
			index = nextSpace
		end
	end

	return parts
end


fw.hook.Add('PlayerSay', function(pl, text)
	local firstSpace = string.find(text, '%s')
	local prefix = string.sub(text, 1, 1)
	local command = string.sub(text, 2, firstSpace and firstSpace - 1 or nil)
	if prefix == '!' or prefix == '/' and fw.chat.cmds[command] then
		command = fw.chat.cmds[command]
		local arguments
		if firstSpace then
			arguments = fw.chat.parseLine(string.sub(text, firstSpace))
		else
			arguments = {}
		end
		if #arguments < #command.params then
			pl:FWChatPrintError("Sorry! This command takes " .. (#command.params) .. " arguments!")
			return
		end

		-- make the last argument into one argument
		if #arguments > #command.params then
			local extra = {}
			for i = #command.params, #arguments do
				table.insert(extra, arguments[i])
				arguments[i] = nil
			end
			arguments[#command.params] = table.concat(extra, ' ')
		end

		local allGood = true

		local function processArguments(index, a, ...)
			if not a then return end

			local param = command.params[index]
			local value, message = fw.chat.argTypes[param.type](a)
			if value == nil and message ~= nil then
				allGood = false
				pl:FWChatPrintError("Error: " .. tostring(message))
				return
			end

			return value, processArguments(index + 1, ...)
		end

		local function callIt(...)
			if allGood then
				command.callback(pl, ...)
				return
			end
		end
		callIt(processArguments(1, unpack(arguments)))

		return ''
	end
	return nil
end)

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

			fw.notif.chatPrint(player.GetAll(), color_black, "[Votes]: ", color_white, "'"..decision.. "' won in ", ply, "'s vote, with, ".. results.yesVotes .." Yes votes, and ".. results.noVotes .." No votes!")

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
			filter = function(ent) if ent != ply then return true end end
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
	['meharryp'] ={
		"memes",
		"yeah go fuck a moose and drink your maple syrup"
	},
	['aStonedPenguin'] ={
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

		fw.notif.chatPrint(player.GetAll(), Color(0, 0, 0), "[Bot] ", Color(255, 255, 255), "Definition of "..searc..": "..def["definition"].."\n".."Usage: "..def["example"])

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

--TODO: Find new api service for querying titles from web pages
--[[
local function ParseURL(sURL, fCallback) //since it's not instant we won't return anything.
	http.Fetch("http://decenturl.com/api-title?u="..sURL or "http://www.google.com", function(body, len, headers, code)
		print(body)
		local tbl = util.JSONToTable(body or "[]");
		if (not tbl or not tbl[2]) then tbl = "No title! :(" else tbl = tbl[2] end
		fCallback(tbl, headers);
	end, function(err)
		ErrorNoHalt(err);
	end)
end

hook.Add("PlayerSay", "QueryForURL", function(ply, text)
	if (string.find(text, "www.")) then
		local exp = string.Explode(" ", text);
		for k, v in ipairs(exp) do
			if (string.find(v, "www.")) then
				ParseURL(v, function(str)
					fw.notif.chatPrint(player.GetAll(), Color(0, 0, 0), "[Bot] ", Color(255, 255, 255), str)
				end)
			end
		end
	end
end)]]
