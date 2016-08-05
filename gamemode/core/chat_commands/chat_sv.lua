fw.chat.cmds = fw.chat.cmds or {}
fw.chat.cmdCache = {}
fw.chat.paramTypes = fw.chat.paramTypes or {}
fw.chat.restrictions = {}
local cmdobj = {}

fw.chat.restrictions["admin"] = function(ply) return ply:IsAdmin() end
fw.chat.restrictions["superadmin"] = function(ply) return ply:IsSuperAdmin() end
fw.chat.restrictions["boss"] = function(ply) return ply:isFactionBoss() end
fw.chat.restrictions["faction"] = function(ply) return ply:inFaction() end
fw.chat.restrictions["alive"] = function(ply) return ply:Alive() end


function cmdobj:addParam(name, type)
	table.insert(self.parameters, {
		name = name, 
		type = type
	})

	return self
end

function cmdobj:restrictTo(perm)
	if (not fw.chat.restrictions[perm]) then
		fw.print('invalid permission type attempted to be registered!', perm)
	end

	table.insert(self.permissions, perm)

	return self
end

local count = 1
function fw.chat.addCMD(cname, chelp, cfunc)
	local obj = {}

	setmetatable(obj, {__index = cmdobj})

	cname = not istable(cname) and {cname} or cname

	--lowercase all the cmds
	for k,v in pairs(cname) do
		cname[k] = string.lower(v)

		concommand.Add("fw_" .. cname[k], function(ply, cmd, args, argStr)
			fw.chat.parseString(ply, "!"..cmd:sub(4 --[[length of fw_ prefix + 1]]).." "..argStr)
		end)
		
		--assign all the possible chat command alternatives to an id, to be referenced by later when it's ran, so we don't make huge ass duplicates of cmds
		fw.chat.cmdCache[ cname[k] ] = count
	end

	obj.id = count
	obj.help = chelp
	obj.callback = cfunc
	obj.parameters = {}
	obj.permissions = {}

	fw.chat.cmds[count] = obj

	count = count + 1
	--support for calling commands via the console
	return obj
end

-- thelastpenguin's quote parser gist
local quotes = {
	['\''] = true,
	['\"'] = true
}
function fw.chat.parseString(line)
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

fw.chat.paramTypes["player"] = function(data)
	local isid = (string.sub(data, 1, 5) == "STEAM") -- is the data passed a steam id?

	for k,v in pairs(player.GetAll()) do
		if (isid and v:SteamID() == data) then
			return v
		end
		if (string.find( string.lower(v:Nick()), string.lower(data))) then -- match the steamid, or match the nickname
			return v
		end
	end

	return data
end
fw.chat.paramTypes['bool']   = function(data) return tobool(data) end
fw.chat.paramTypes['number'] = function(data) return tonumber(data) end
fw.chat.paramTypes['string'] = function(data) return tostring(data) end

function fw.chat.parseString(ply, str)
	--get cmd name
	local string_parts = string.Explode(" ", str)
	local cmdn = string_parts[1]

	--make sure the player is trying to call a cmd
	local first = string.sub(cmdn, 1, 1)
	if (not first:match("^[!/$#@]")) then
		return
	end

	--make sure the command oject exists
	cmdn = string.sub(cmdn, 2, string.len(cmdn))
	cmdn = string.lower(cmdn)

	--grab the id associated with the command! :D
	local cmdID = fw.chat.cmdCache[cmdn]
	if (not cmdID) then fw.print('cmdid', cmdID, 'not found') return str end

	--index the cmd based on the cmd id
	local cmdObj = fw.chat.cmds[cmdID]
	if (not cmdObj) then fw.print('cmdn', cmdn, 'not found') return str end

	if (#cmdObj.permissions > 0) then
		for k,v in pairs(cmdObj.permissions) do
			local build = fw.chat.restrictions[v]

			if (not build(ply)) then 
				ply:FWChatPrintError("You don't meet the qualifications to run this command!")
				return str
			end
		end
	end

	table.remove(string_parts, 1)

	--get the arguments, with quote sensitivity
	local args = fw.chat.parseQuotes(table.concat(string_parts, ' '))

	--get ready for assigning arguments to parameters, as required by the command
	local params = cmdObj.parameters
	local parsedArguments = {}

	--assign a count for easier indexing of args
	local count = 1

	--here we will assign each parameter a value and return it to the function, in a very neat fashion
	for k,v in pairs(params) do
		local pName = v.name
		local pType = v.type

		local value = args[k] --where are we in the string the player sent?
		if (not value) then
			ply:FWChatPrintError(Color(255, 0, 0), ' Command requires ' .. #params .. ' arguments, failed to run.')
			return str
		end

		--the player is targeting themself
		if (pType == 'player' and value == '^') then
			value = ply
		elseif (pType == 'string' and (params[k + 1] == nil)) then
			local func = fw.chat.paramTypes['string']
			-- very efficient way of splicing the arguments table, dropping the first k-1 values, and then creating a new table and joining it with ' '
			value = table.concat({select(k, unpack(args))}, ' ')
			value = func(value)

			if (not value) then 
				return str
			end
		else
			local func = fw.chat.paramTypes[pType] or fw.chat.paramTypes['string']
			value = func(value)

			if (not value) then
				ply:FWChatPrintError('Failed to parse parameter #' .. k .. ' did not run command.')
				return str
			end
		end

		table.insert(parsedArguments, value)
		count = count + 1
	end

	cmdObj.callback(ply, unpack(parsedArguments))
	
	return ""
end

fw.hook.Add("PlayerSay", "ParseForCommands", function(ply, text, teamChat)
	if (text[1] == '^') then 
		if (ply.lastmsg) then 
			text = ply.lastmsg
		end
	else 
		ply.lastmsg = text
	end

	if (teamChat) then
		ply:ConCommand("fw_group "..text)

		return ""
	end

	--did the chat cmd ran, return a string? if so, then return the string is sent :D
	local status = fw.chat.parseString(ply, text)
	if (status) then 
		return ""
	end


	local textCache = {}
	if (not ply:Alive()) then
		table.insert(textCache, Color(255, 0, 0))
		table.insert(textCache, "*DEAD* ")
	end

	local user, color = fw.hook.Call("ChatTags", GAMEMODE, ply)

	if (user and color) then
		table.insert(textCache, color)
		table.insert(textCache, user)
	end

	table.insert(textCache, team.GetColor(ply:Team()))
	table.insert(textCache, ply:Nick() .. ": ")
	table.insert(textCache, Color(255, 255, 255))

	table.insert(textCache, text)

	local players = {}
	for k,v in pairs(player.findInSphere(ply:GetPos(), 260)) do
		if (not v:IsPlayer()) then continue end
		
		table.insert(players, v)
	end

	fw.notif.chat(players, unpack(textCache))

	return ""
end)

--basic /me command
--[[ -- broken and not important enough to be worth fixing
fw.chat.addCMD("me", "Sends a message spoofing yourself", function(ply, text)
	ply:FWChatPrint(team.GetColor(ply:Team()), ply:Nick(), " ", text)
end):addParam('message', 'string')
]]

--basic help command
fw.chat.addCMD("help", "Prints a help log to your screen", function(ply)
	ply:FWConPrint( "------------NOTE------------")
	ply:FWConPrint("THE ORDER MATTERS WITH PARAMETERS. FOLLOW USAGE GUIDE.")

	for k,v in pairs(fw.chat.cmds) do
		ply:FWConPrint("----------------")
		ply:FWConPrint("Command: " .. k)
		ply:FWConPrint("Help: ".. v.help)

		local usage = "/"..k.." "

		for k,v in pairs(v.parameters) do
			ply:FWConPrint("Param: ".. v.name.. ', accepts type ' ..v.type)
			usage = usage .. v.name .. " <"..v.type..">"
		end
		ply:FWConPrint("Usage: "..usage)
	end
	ply:FWChatPrint(Color(255, 255, 255), 'A list of all available commands has printed to your console!')
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
			filter = function( ent ) if ent != ply then return true end end
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

