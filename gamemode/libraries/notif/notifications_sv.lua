
util.AddNetworkString('fw.notif.conprint')
util.AddNetworkString('fw.notif.chatprint')
util.AddNetworkString('fw.notif.banner')

local Player = FindMetaTable('Player')

local net = net 

local function sendHelper(a, ...)
	if a == nil then return net.WriteUInt(0, 2) end
	if type(a) == 'table' then 
		net.WriteUInt(1, 2)
		net.WriteUInt(a.r, 8)
		net.WriteUInt(a.g, 8)
		net.WriteUInt(a.b, 8)
	elseif type(a) == 'string' then
		net.WriteUInt(2, 2)
		net.WriteString(tostring(a))
	end
	sendHelper(...)
end

local function fwConPrint(players, ...)
	net.Start('fw.notif.conprint')
		sendHelper(...)
	net.Send(players)
end

local function fwChatPrint(players, ...)
	net.Start('fw.notif.chatprint')
		sendHelper(...)
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
