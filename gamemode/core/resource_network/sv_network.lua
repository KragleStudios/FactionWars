
-- BUGS BUGS EVERYWHERE:
-- Entities sometimes dont update, at some point.. cant remember exactly when.. Ill work it out
-- Probably more but these are all that come to mind

local network = {}
network.__index = network
network.networks = {}
local id = 1

function network.create(ent, radius)
	if not IsValid(ent) then return end
	local netwrk = setmetatable({["src"] = ent:GetPos(), ["radius"] = radius, ["id"] = id, ["ent"] = ent, ["subnets"] = {}, ["enabled"] = true, ["rescgen"] = {}, ["receivers"] = {}, ["output"] = {}, ["overloaded"] = true}, network)
	ent.net = netwrk
	network.networks[id] = netwrk
	id = id + 1

	netwrk:ResourceInit()

	netwrk:CheckRadius()

	netwrk:CheckReceivers()

	netwrk:UpdateAllGenerationCost()

	return netwrk
end

function network:CheckRadius()
	for k,v in pairs (network.networks) do
		print(v:GetID(), self:GetID(), v:GetPos():Distance(self:GetPos()) ,v:GetPos():Distance(self:GetPos()) < self:GetRadius(), self:GetPos())
		if v:GetPos():Distance(self:GetPos()) < self:GetRadius() and v != self and self:IsEnabled() and v:IsEnabled() then
			self.subnets[v.id] = v:GetEntity()
			v.subnets[self.id] = self:GetEntity()
		end
	end
end

function network:Remove()
	for k,v in pairs(self.receivers) do
		v:RemoveNode()
	end
	network.networks[self.id] = nil
end

function network:CheckNetValidity()
	for k,v in pairs(self.subnets) do
		if IsValid(v) then 
			continue 
		else 
			print("deleted	", v, self.subnets[k], k)
			self.subnets[k] = nil
		end
	end
end

function network:Clear()
	self.subnets = {}
end

function network:ResourceInit()
	for k,v in pairs(fw.resource.manager.getResources()) do
		self.rescgen[k] = (self.ent.Generation[k] || 0)
	end
	self.output = table.Copy(self.rescgen) -- Copy the default resource gen, since its just been spawned nothing is using it
end

function network:Update()
	self:UpdateAllGenerationCost()
	self:CheckReceivers()
	self:CheckRadius()
end

function network:UpdateGenerationCost(class)
	local cost = self:GetClassGenerationCost(class)
	print("Cost: ", self:GetID(), cost, class)
	self:ShareOutputCosts(cost, class)
end

function network:UpdateAllGenerationCost()
	for k,v in pairs(fw.resource.manager.getResources()) do
		self:UpdateGenerationCost(k)
	end
end

-- Bug: Loses 1 charge everytime we cross a generator threshold, is fixed by picking the node up and placing it back down
function network:ShareOutputCosts(cost, class)
	local nodes = self:GetNodes()
	local resc = self:GetSharedRescourceAvailable(class)
	print("Sharing Costs: ", resc, cost, class, table.Count(nodes))
	local carry = self:UseResourceAvailable(class, cost)
	print("Carry: ", carry)
	if carry > 0 then
		print("moving onto next node")
		for k,v in pairs(nodes) do
			if carry <= 0 then break end
			carry = v:UseResourceAvailable(class, carry)
			print("Next Node: ", carry)
		end
	end

	if carry > 0 then -- Couldnt allocate extra resources
		self:SetOverloaded(true)
	else
		self:SetOverloaded(false)
	end
		print("Network Overload: ", self:IsOverloaded())
end

function network:CheckReceivers()
	local changed = false

	for k,v in pairs(self.receivers) do -- Remove entities that are out of range or invalid
		if !IsValid(v) then self.receivers[k] = nil continue end
		if v:GetPos():Distance(self:GetPos()) > self:GetRadius() then
			print("Removed :", v , "No longer in distance for network")
			--self.receivers[k] = nil
			self:RemoveReceiver(v)
			v:RemoveNode()
			changed = true 
		end
	end

	for k,v in pairs(ents.GetAll()) do -- Add any entities that are now in range
		if v:IsNode() || v.GenerationRequirements == nil || v.connectednet != nil then continue end
		if v:GetPos():Distance(self:GetPos()) < self:GetRadius() then
			--self.receivers[v:EntIndex()] = v
			self:AddReceiver(v)
			v:SetNode(self)
			print("Added new ent: ", v, "Was in range!")
			changed = true
		end
	end

	if changed then
		self:UpdateAllGenerationCost()
		print("Updated generating cost, something was changed")
	end
end

-- Getters/Setters

function network:GetClassGenerationCost(class)
	local amt = 0
	for k,v in pairs(self.receivers) do
		if v.GenerationRequirements && v.GenerationRequirements[class] then
			amt = amt + v.GenerationRequirements[class]
		end
	end
	return amt
end

function network:GetSharedResource(class)
	local nodes = self:GetNodes()
	local amt = self:GetResourceGeneration(class) -- nodes does not include itself
	for k,v in pairs(nodes) do
		amt = amt + v.rescgen[class]
	end
	print("Total Network Resources: ", amt)
	return amt
end

function network:GetSharedRescourceAvailable(class)
	local nodes = self:GetNodes()
	local amt = self:GetResourceAvailable(class)
	for k,v in pairs(nodes) do
		amt = amt + v:GetResourceAvailable(class)
	end
	return amt
end

function network:GetNodes() -- This needs to be cached, and updated when the local subnet changes
	local nodes = {}
	local function GetNodes(net)
		for k,v in pairs(net.subnets) do
			if nodes[v.net:GetID()] || v.net:GetID() == self:GetID() then continue end
			nodes[v.net:GetID()] = v.net
			GetNodes(v.net)
		end
		return nodes
	end

	for k,v in pairs(self.subnets) do
		if v.net and v.net:GetID() == self:GetID() then continue end
		nodes[v.net:GetID()] = v.net
		table.Merge(nodes, GetNodes(v.net))
	end
	return nodes
end

function network:GetResourcesGeneration()
	return self.rescgen
end

function network:GetResourceGeneration(class)
	return self.rescgen[class]
end

function network:GetResourceAvailable(class)
	return self.output[class]
end

function network:UseResourceAvailable(class, amt)
	self.output[class] = self.rescgen[class] -- Reset the output, when we recalculate
	if self.output[class] - amt < 0 then
		print("Its less than zero")
		local carry = math.abs(self.output[class] - amt)
		self.output[class] = self.output[class] - amt + math.abs(self.output[class] - amt)
		print(self.output[class] - amt + math.abs(self.output[class] - amt), self.output[class] - amt, carry)
		return math.abs(carry) -- Return the amount left over
	else
		self.output[class] = self.output[class] - amt
		return 0
	end
end

function network:AddResource(class, val)
	self.rescgen[class] = self.rescgen[class] + val
end

function network:SetOverloaded(b)
	self.overloaded = b
end

function network:IsOverloaded()
	return self.overloaded
end

function network:AddReceiver(ent)
	self.receivers[ent:EntIndex()] = ent
end

function network:RemoveReceiver(ent)
	self.receivers[ent:EntIndex()] = nil
end

function network:GetReceivers()
	return self.receivers
end

function network:SetEnable(b)
	self.enabled = b
end

function network:IsEnabled() -- I dont this is consitent? But it sounds so much better..
	return self.enabled
end

function network:SetPos(vec)
	self.src = vec
end

function network:GetPos()
	return self.src
end

function network:SetRadius(rad)
	self.radius = rad
end

function network:GetRadius()
	return self.radius
end

function network:GetEntity()
	return self.ent
end

function network:GetID()
	return self.id
end

return network