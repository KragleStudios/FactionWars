
util.AddNetworkString('fw.notif.conprint')
util.AddNetworkString('fw.notif.chatprint')
util.AddNetworkString('fw.notif.banner')

local Player = FindMetaTable('Player')

local function fwConPrint(players, ...)
	local args = {...}

	for k, v in ipairs(args) do
		if (IsColor(v) and fw.notif.colors[v]) then
			args[k] = fw.notif.colors[v]
		end
	end

	net.Start('fw.notif.conprint')
		net.WriteTable(args)
	net.Send(players)
end

local function fwChatPrint(players, ...)
	local args = {...}

	for k, v in ipairs(args) do
		if (IsColor(v) and fw.notif.colors[v]) then
			args[k] = fw.notif.colors[v]
		end
	end

	net.Start('fw.notif.chatprint')
		net.WriteTable(args)
	net.Send(players)
end

fw.notif.chatPrint = fwChatPrint
fw.notif.conPrint = fwConPrint

function Player:FWConPrint(...)
	fwConPrint(self, ...)
end

function Player:FWChatPrint(...)
	fwChatPrint(self, ...) 
end

function Player:FWChatPrintError(...)
	fwChatPrint(self, color_black, '[Error] ', Color(255, 0, 0), ...)
end
