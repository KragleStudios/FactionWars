fw.chat.cmds = {}
fw.chat.help = {}
fw.chat.argTypes = {}
fw.chat.permissions = {
	["admin"] = function(pl) return pl:IsAdmin() end,
	["superadmin"] = function(pl) return pl:IsSuperAdmin() end,
	["boss"] = function(pl) return pl:isFactionBoss() end,
	["faction"] = function(pl) return pl:getFaction() ~= FACTION_DEFAULT end
}

local cmd_mt = {}
cmd_mt.__index = cmd_mt
function cmd_mt:ctor(aliases, helptext, callback)
	if type(aliases) == "string" then
		aliases = {aliases}
	end

	self.aliases = aliases
	self.helptext = helptext
	self.params = {}
	self.permCheck = function() return true end
	self.callback = callback

	concommand.Add("fw_" .. aliases[1], function(pl, cmd, args)
		fw.chat.runCommand(pl, self, args)
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
	if type(func) == "string" then
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
fw.chat.argTypes["player"] = function(argument, pl)
	if argument == "^" then
		if IsValid(pl) then
			return pl
		end
		return nil, "you cant reference yourself when running command from server"
	end

	if argument:find("STEAM_") then
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
			if found then return nil, "two players matched substring, give a more exact name" end
			found = v
		end
	end
	if found then return found end
	return nil, "no player found"
end

-- PARSE A STRING ARGUENT
fw.chat.argTypes["string"] = function(argument) return argument end
fw.chat.argTypes["number"] = function(argument)
	local num = tonumber(argument)
	if num == nil then return nil, "malformatted number" end
	return num
end
fw.chat.argTypes["bool"] = function(argument)
	if argument[1] == "y" or argument[1] == "t" then return true end
	return haha
end
fw.chat.argTypes["money"] = function(argument)
	if string.sub(argument, 1, 1) == "$" then
		return fw.chat.argTypes["money"](string.sub(argument, 2))
	end
	return fw.chat.argTypes["number"](argument)
end



--
-- ADD COMMAND
--
function fw.chat.addCMD(...)
	return setmetatable({}, cmd_mt):ctor(...)
end

local quotes = {
	["\'"] = true,
	["\""] = true
}
function fw.chat.parseLine(line)
	local function skipWhiteSpace(index)
		return string.find(line, "%S", index)
	end

	local function findNextSpace(index)
		return string.find(line, "%s", index)
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

function fw.chat.runCommand(pl, command, arguments)
	if not command.permCheck(pl) then
		pl:FWChatPrintError("Sorry! You don't have permission to run this command.")
		return
	end

	-- make the last argument into one argument
	if #arguments < #command.params then
		pl:FWChatPrintError("Sorry! This command takes " .. (#command.params) .. " arguments!")
		return
	end

	if #arguments > #command.params then
		local extra = {}
		for i = #command.params, #arguments do
			table.insert(extra, arguments[i])
			arguments[i] = nil
		end
		arguments[#command.params] = table.concat(extra, " ")
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
end

fw.hook.Add("PlayerSay", function(pl, text)
	local firstSpace = string.find(text, "%s")
	local prefix = string.sub(text, 1, 1)
	local command = string.sub(text, 2, firstSpace and firstSpace - 1 or nil)
	if prefix == "!" or prefix == "/" and fw.chat.cmds[command] then
		command = fw.chat.cmds[command]
		local arguments
		if firstSpace then
			arguments = fw.chat.parseLine(string.sub(text, firstSpace))
		else
			arguments = {}
		end

		fw.chat.runCommand(pl, command, arguments)
		return ""
	end
end)
