if SERVER then AddCSLuaFile() end

fw.dep(SHARED, 'notif')
fw.dep(SERVER, 'hook')

file.CreateDir(fw.config.dataDir)

local Player = FindMetaTable('Player')
local Entity = FindMetaTable('Entity')

-- Player:GetFWData()
-- @param amount:number - the amount of money to add
-- @ret amount:number player's current balance
if SERVER then 
	function Player:GetFWData()
		return ndoc.table.fwPlayers[self]
	end

	function Entity:GetFWData()
		local data = ndoc.table.fwEntities[self:EntIndex()]
		if not data then
			local index = self:EntIndex()
			ndoc.table.fwEntities[index] = {}
			return ndoc.table.fwEntities[index]
		end
		return data 
	end

	fw.hook.Add('EntityRemoved', function(ent)
		if ndoc.table.fwEntities[ent:EntIndex()] then 
			ndoc.table.fwEntities[ent:EntIndex()] = nil
		end
	end)
else
	local noData = setmetatable({}, {__newindex = function(self, key) rawset(self, key, nil) end})

	function Player:GetFWData()
		return ndoc.table.fwPlayers and ndoc.table.fwPlayers[self] or noData
	end

	function Entity:GetFWData()
		return ndoc.table.fwEntities[self:EntIndex()] or noData
	end
end

fw.include_sv 'data_sv.lua'