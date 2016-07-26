fw.chat.cmds = fw.chat.cmds or {}
fw.chat.paramTypes = fw.chat.paramTypes or {}
local cmdobj = {}

function cmdobj:addParam(name, type)
	table.insert(self.parameters, {
		name = name, 
		type = type
	})

	return self
end

function fw.chat.addCMD(cname, chelp, cfunc)
	local obj = {}

	setmetatable(obj, {__index = cmdobj})

	cname = string.lower(cname)

	obj.name = cname
	obj.help = chelp
	obj.callback = cfunc
	obj.parameters = {}

	fw.chat.cmds[cname] = obj

	--support for calling commands via the console
	concommand.Add("fw_" .. cname, function(ply, cmd, args, argStr)
		fw.chat.parseString(ply, "!"..cmd:sub(4 --[[length of fw_ prefix + 1]]).." "..argStr)
	end)

	return obj
end

--THIS WAS NOT MADE BY BE. ALL CREDIT GOES TO THE ORIGINAL AUTHOR.
function fw.chat.parseQuotes(input)
	local ret = {}
	local len = string.len(input)
	
	local literal = false
	local quote = false
	local current = ""
	
	for i = 0, len do
	
		local c = input[i]
		
		if literal then
			if c == '\"' then
				quote = not quote
			else
				c = special[c] or c
				current = current .. c
			end
			literal = false
		else
			if c == '\"' then
				quote = not quote
			elseif c == '\\' then
				literal = true
			elseif c == ' ' and not quote then
				table.insert(ret, current)
				current = ""
			else
				current = current .. c
			end
		end
		
	end
	
	if string.len(current) != 0 then
		table.insert(ret, current)
	end
	
	return ret
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

	local cmdObj = fw.chat.cmds[cmdn]
	if (not cmdObj) then fw.print('cmdn', cmdn, 'not found') return str end

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

fw.hook.Add("PlayerSay", "ParseForCommands", function(ply, text)
	if (text[1] == '^') then 
		if (ply.lastmsg) then 
			text = ply.lastmsg
		end
	else 
		ply.lastmsg = text
	end

	return fw.chat.parseString(ply, text) or text
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
		local tr = util.TraceLine( {
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
			filter = function( ent ) if ent != ply then return true end end
		} )

		ply:addMoney(-money)

		local ent = ents.Create("fw_money")
		ent:SetValue(money)
		ent:SetPos(tr.HitPos)
		ent:Spawn()
	end
end):addParam("money", "number")

fw.chat.addCMD("drop", "Drop your weapon", function(ply)
	if not fw.config.dropBlacklist[ply:GetActiveWeapon():GetClass()] then
		ply:DropWeapon(ply:GetActiveWeapon())
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
	},
	['Spai'] = {
		"Editing DarkRP, anyone can do it, but it is all about how you edit it, that is what not everyone can do correctly. - Commander Grox",
	},
	['Mikey Howell'] = {
		"do you realise you're saying lastest",
	},
	['crazyscouter'] = {
		"Use effects.halo.Add()",
		"Guys I just realized I've been using the women's restroom the entire time I've been at this restaraunt",
	},
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

