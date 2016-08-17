if SERVER then AddCSLuaFile() end

fw.dep(SHARED, 'notif')
fw.dep(SERVER, 'hook')

file.CreateDir(fw.config.dataDir)

local Player = FindMetaTable('Player')

-- Player:GetFWData()
-- @param amount:number - the amount of money to add
-- @ret amount:number player's current balance
if SERVER then
	ndoc.table.fwPlayers = {}

	local playerData = ndoc.table.fwPlayers

	function Player:GetFWData()
		return playerData[self:EntIndex()]
	end

else
	local playerData = {}
	ndoc.observe(ndoc.table, 'wait for fwPlayers', function()
		playerData = ndoc.table.fwPlayers or {}
	end, ndoc.compilePath('fwPlayers'))

	local noData = setmetatable({}, {__newindex = function(self, key) rawset(self, key, nil) end})

	function Player:GetFWData()
		return playerData[self:EntIndex()] or noData
	end

end

fw.include_sv 'data_sv.lua'
