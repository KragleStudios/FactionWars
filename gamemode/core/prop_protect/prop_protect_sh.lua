function fw.pp.canPhysgunProp(target, ent)
	local owner = ent:FWGetOwner()

	if (not owner) then return false end

	local data = ndoc.table.pp[owner]
	if (not data) then return false end

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
	if (not data) then return false end

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
if SERVER then
	function entity:FWGetOwner()
		return self.owner
	end
else
	function entity:FWGetOwner()
		return self:GetNWEntity('owner')
	end
end

if (SERVER) then
	function entity:FWSetOwner(owner)
		self.owner = owner
		self:SetNWEntity("owner", owner)
	end
end

fw.hook.Add("CanTool", "PreventBaddieTools", function(ply, tr)
	if (tr.Entity and tr.Entity:GetClass() == "prop_physics") then
		return fw.pp.canToolProp(ply, tr.Entity)
	end
	if (tr.Entity and tr.Entity:IsPlayer()) then return false end

	return true
end)
