function fw.pp.canPhysgunProp(target, ent)
	local owner = ent:FWGetOwner()

	if (not owner) then return false end

	local data = ndoc.table.pp[owner]

	local whoCanPhysgun = data.whoCanPhysgun
	local whoCanTool    = data.whoCanTool

	if (whoCanPhysgun == 0) then 
		return true 
	elseif (whoCanPhysgun == 1) then
		if (data.whitelist[target]) then return true end 
	elseif (whoCanPhysgun == 2) then
		if (owner:getFaction() == target:getFaction()) then return true end
	end
	if (target == owner) then return true end


	return false
end

function fw.pp.canToolProp(target, ent)
	local owner = ent:FWGetOwner()

	if (not owner) then return false end

	local data = ndoc.table.pp[owner]

	local whoCanTool = data.whoCanTool

	if (whoCanTool == 0) then 
		return true 
	elseif (whoCanTool == 1) then
		if (data.whitelist[target]) then return true end 
	elseif (whoCanTool == 2) then
		if (owner:getFaction() == target:getFaction()) then return true end
	end
	if (target == owner) then return true end

	return false
end


local entity = FindMetaTable("Entity")
function entity:FWGetOwner()
	return SERVER and self.owner or self:GetNWEntity("owner")
end

if (SERVER) then
	function entity:FWSetOwner(owner)
		self.owner = owner
		self:SetNWEntity("owner", owner)
	end
end
