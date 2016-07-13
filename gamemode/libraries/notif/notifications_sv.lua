
util.AddNetworkString('fw.notif.conprint')
util.AddNetworkString('fw.notif.chatprint')
util.AddNetworkString('fw.notif.banner')

local Player = FindMetaTable('Player')


local function fwConPrint(players, ...)
	net.Start('fw.notif.conprint')
	net.WriteTable {...}
	net.Send(players)
end

local function fwChatPrint(players, ...)
	net.Start('fw.notif.chatprint')
	net.WriteTable {...}
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
	fwChatPrint(self, Color(0, 0, 0), '[Faction Wars]', Color(255, 0, 0), ...)
end