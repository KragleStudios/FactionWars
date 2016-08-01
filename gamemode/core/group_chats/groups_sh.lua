function fw.group.registerChatGroup(name, ...)
	local teamChat = {...}
	local cache = {}

	for k, v in pairs(teamChat) do
		cache[v] = true
	end

	fw.group.chats[name] = cache
end

function fw.group.registerVoiceGroup(...)
	local teamChat = {...}
	local cache = {}

	for k, v in pairs(teamChat) do
		cache[v] = true
	end

	table.insert(fw.group.voice, cache)
end

local Player = FindMetaTable("Player")