fw.chat.cmds = fw.chat.cmds or {}
fw.chat.paramTypes = fw.chat.paramTypes or {}
local cmdobj = {}

function cmdobj:addParam(name, type)
	table.insert(self.parameters, {name, type})

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
	if (not first:match("^[!/$#@]")) then print(1)
		return str
	end

	--make sure the command oject exists
	cmdn = string.sub(cmdn, 2, string.len(cmdn))
	local cmdObj = fw.chat.cmds[cmdn]
	if (not cmdObj) then print(2) return str end

	table.remove(string_parts, 1)

	--get the arguments, with quote sensitivity
	local args = fw.chat.parseQuotes(table.concat(string_parts, ' '))

	--get ready for assigning arguments to parameters, as required by the command
	local params = cmdObj.parameters
	local structure = {}

	--assign a count for easier indexing of args
	local count = 1

	--here we will assign each parameter a value and return it to the function, in a very neat fashion
	for k,v in pairs(params) do
		local pName = v[1]
		local pType = v[2]

		local value = args[1] --where are we in the string the player sent?
		if (not value) then
			--NOTIFY CAN'T CONTINUE BECAUSE OF MISSING PARAMETER VALUE
			return str
		end



		--the player is targeting themself
		if (pType == 'player' and value == '^') then
			value = ply
		elseif (pType == 'string' and (params[k + 1] == nil)) then

			local func = fw.chat.paramTypes['string']
			value = table.concat(args, ' ')
			value = func(value)

			if (not value) then 
				return str
			end
		else
			local func = fw.chat.paramTypes[pType] or fw.chat.paramTypes['string']
			value = func(value)

			if (not value) then
				--NOTIFY CAN"T CONTINUE BECAUSE OF MISSING PARAMETER VALUE
				return str
			end

			
		end

		table.insert(structure, value)
		count = count + 1
		
		table.remove(args, 1) --for getting remainder of string
	end
	
	cmdObj.callback(ply, unpack(structure))
	return ""
end

hook.Add("PlayerSay", "ParseForCommands", function(ply, text)
	if (string.match('^[^]', string.sub(text, 1, 1))) then 
		if (ply.lastmsg) then 
			text = ply.lastmsg
		end
	else 
		ply.lastmsg = text
	end

	return fw.chat.parseString(ply, text) or text
end)