if SERVER then AddCSLuaFile() end

fw.dep(SHARED, 'notif')
fw.dep(SERVER, 'hook')

local Player = FindMetaTable('Player')
-- Player:GetFWData()
-- @param amount:number - the amount of money to add
-- @ret amount:number player's current balance
function Player:GetFWData()
	return ndoc.table.fwPlayers[self]
end


fw.include_sv 'data_sv.lua'