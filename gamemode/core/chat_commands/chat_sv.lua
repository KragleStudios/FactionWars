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

	obj.name = cname
	obj.help = chelp
	obj.callback = cfunc
	obj.parameters = {}

	fw.chat.cmds[cname] = obj

	--support for calling commands via the console
	concommand.Add("fw_" .. cname, function(ply, cmd, args, argStr)
		fw.chat.parseString(ply, "!"..cmd:gsub("fw_", "").." "..argStr) --spoof a chat command structure (lol)
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
		return str
	end

	--make sure the command oject exists
	cmdn = string.sub(cmdn, 2, string.len(cmdn))

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
			ply:FWChatPrintError(Color(0, 0, 0), '[Faction Wars] ', Color(255, 0, 0), ' Command requires ' .. #params .. ' arguments, failed to run.')
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

hook.Call("FWChatLibraryLoaded", GAMEMODE)

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
fw.chat.addCMD("me", "Sends a message spoofing yourself", function(ply, text)
	ply:FWChatPrint(team.GetColor(ply:Team()), ply:Nick(), " ", text)
end):addParam('message', 'string')

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
			ply:FWConPrint("Param: ".. v[1].. ', accepts type ' ..v[2])
			usage = usage .. v[1].. " < "..v[2].." >"
		end
		ply:FWConPrint("Usage: "..usage)
	end
	ply:FWChatPrint(Color(0, 0, 0), '[Faction Wars]: ', Color(255, 255, 255), 'A list of all available commands has printed to your console!')
end)

fw.chat.addCMD("vote", "Makes a vote available to everyone", function(ply, desc)
	fw.vote.createNew(ply:Nick().."'s vote", desc, player.GetAll(), 
		function(decision, vote, results) 
			PrintTable(results)
			for k,v in pairs(player.GetAll()) do
				v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Votes]: ", Color(255, 255, 255), "'"..decision.. "' won in "..ply:Nick().."'s vote, with, ".. results[1] .." Yes votes, and ".. results[2] .." No votes!")
			end
		end, "Yes", "No", 15)
end):addParam("description", "string")