local fw = fw

local net_WriteUInt = net.WriteUInt
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable

--
-- RESOURCE ENTITIES
--
ndoc.table.fwEntityResources = ndoc.table.fwEntityResources or {}


local resource_entities = __FW_RESOURCE_ENTITIES or {}
__FW_RESOURCE_ENTITIES = resource_entities

function fw.resource.addEntity(ent)
	ent.fwResources = {} -- how much of each resource they have!
	ent.fwResourcesStatic = {} -- resources that are static or don't get cleared every update
	ent.fwProductionUse = {} -- how much of its production is actually getting used
	table.insert(resource_entities, ent)

	ndoc.table.fwEntityResources[ent:EntIndex()] = {
		haveResources = {}, -- how much of each resource it has
		amProducing = {}, -- how much of each resource it produces
		amStoring = {}, -- how much of each resource it stores
		productionBeingUsed = {}, -- how much of what it produces gets used
	}

	if SERVER then
		fw.resource.updateNetworks()
	end
end

function fw.resource.removeEntity(ent)
	ndoc.table.fwEntityResources[ent:EntIndex()] = nil
	table.RemoveByValue(resource_entities, ent)
end

--
-- FUN WITH ALGORITHMS
--
local autozero_mt = {
		__index = function(self, key)
			self[key] = 0
			return self[key]
		end
	}

local autotable_mt = {
		__index = function(self, key)
			self[key] = {}
			return self[key]
		end
	}

function fw.resource.updateNetworks()
	-- local startTime = SysTime()

	-- fun algorithms by thelastpenguin
	local resTypes = fw.resource.types

	--
	-- STEP 1: construct a graph
	--
	local networks = {}
	do
		local union_find = {}
		local union_find_counts = {}

		for k, ent in pairs(resource_entities) do
			if not IsValid(ent) then -- check that entity is valid. note that removing an entity requires this entire function to run again. it's slow. just call the right functions.
				ErrorNoHalt("[FactionWars] had te remove invalid entity from resource_entities. This should be handled by ENT:OnRemove. Badly coded entity in use.")
				table.remove(resource_entities, k)
				fw.resource.updateNetworks()
				return
			end

			union_find[ent] = ent
			union_find_counts[ent] = 1
		end

		local function root(ent)
			local theRoot = union_find[ent]
			if theRoot == ent then return ent end
			theRoot = root(union_find[ent])
			if theRoot ~= union_find[ent] then union_find[ent] = theRoot end
			return theRoot
		end

		local function union(ent1, ent2)
			local root1 = root(ent1)
			local root2 = root(ent2)
			if root1 == root2 then return end -- already in the same set!

			if union_find_counts[root2] > union_find_counts[root1] then
				local tmp = root2
				root2 = root1
				root1 = tmp
			end
			union_find[root2] = root1
			union_find_counts[root1] = union_find_counts[root1] + union_find_counts[root2]
			union_find_counts[root2] = nil
		end

		-- local startTime2 = SysTime()
		-- TODO: thelastpenguin implement a kdtree benchmarks show that the algorithm spends 90% of it's time in this loop
		for k, ent1 in pairs(resource_entities) do
			local ent1Pos = ent1:GetPos()
			local radius2 = ent1.NETWORK_SIZE * ent1.NETWORK_SIZE
			for k, ent2 in pairs(resource_entities) do
				if ent1 ~= ent2 and ent1Pos:DistToSqr(ent2:GetPos()) < radius2 then
					union(ent1, ent2)
				end
			end
		end
		-- print("union find in ", (SysTime() - startTime2))

		for k, ent in ipairs(resource_entities) do
			local r = root(ent)
			local groupId = r:EntIndex()
			if not networks[groupId] then
				networks[groupId] = {
					id = groupId,
					ents = {},
				}
			end
			table.insert(networks[groupId].ents, ent)
		end
	end

	--
	-- STEP 2: UPDATE NETWORK TOTALS
	--
	for k, network in pairs(networks) do
		local total_consumption = setmetatable({}, autozero_mt)
		local total_production = setmetatable({}, autozero_mt)
		local total_storage = setmetatable({}, autozero_mt)

		local availableProduction = setmetatable({}, autotable_mt)
		local desiredConsumption = setmetatable({}, autotable_mt)
		local availableStorage = setmetatable({}, autotable_mt)

		-- compute available resources
		for k, ent in ipairs(network.ents) do
			if ent.Consumes then
				for type, amount in pairs(ent.Consumes) do
					if resTypes[type] then
						total_consumption[type] = total_consumption[type] + amount
						desiredConsumption[type][ent] = amount
					end
				end
			end

			if ent.Produces and (not ent.IsActive or ent:IsActive()) then
				for type, amount in pairs(ent.Produces) do
					if resTypes[type] then
						total_production[type] = total_production[type] + amount
						availableProduction[type][ent] = amount
					end
				end
			end

			if ent.Storage then
				for type, amount in pairs(ent.Storage) do
					if resTypes[type] then
						total_storage[type] = total_storage[type] + amount
						availableStorage[type][ent] = amount
					end
				end
			end
		end

		network.totalConsumption = total_consumption
		network.totalProduction = total_production
		network.totalStorage = total_storage
		network.producers = availableProduction
		network.consumers = desiredConsumption
		network.storage = availableStorage

		-- clear networking for resources that are no longer available
		for k, ent in ipairs(network.ents) do
			ent.fwNetwork = network
			for type, _ in pairs(ent.fwResources) do
				ent.fwResources[type] = nil
			end
			for type, _ in pairs(ent.fwProductionUse) do
				ent.fwProductionUse[type] = nil
			end
		end

		for type, consumers in pairs(desiredConsumption) do
			local producers = availableProduction[type]
			local currentProducer, canProduce = next(producers, nil)
			if currentProducer then currentProducer.fwProductionUse[type] = 0 end
			for ent, wanted in pairs(consumers) do
				local amount = wanted
				while currentProducer and amount > 0 do
					if canProduce < amount then
						amount = amount - canProduce
						currentProducer.fwProductionUse[type] = curentProducer.Produces[type]
						currentProducer, canProduce = next(producers, currentProducer)
					else
						canProduce = canProduce - amount
						amount = 0
					end
				end

				if ent.fwResources[type] ~= (wanted - amount) then
					ent.fwResources[type] = (wanted - amount)
				end
			end
			if currentProducer then
				currentProducer.fwProductionUse[type] = currentProducer.Produces[type] - canProduce
			end
		end
	end

	--
	-- UPDATE THE NETDOC TABLE
	--
	local function syncupTables(mytable, netdocTable)
		for k,v in pairs(mytable) do
			if netdocTable[k] ~= v then
				netdocTable[k] = v
			end
		end
	end

	local noTbl = {}
	for k, ent in ipairs(resource_entities) do
		local ntable = ndoc.table.fwEntityResources[ent:EntIndex()]
		syncupTables(ent.Produces or noTbl, ntable.amProducing)
		syncupTables(ent.fwProductionUse or noTbl, ntable.productionBeingUsed)
		syncupTables(ent.Storage or noTbl, ntable.amStoring)

		syncupTables(ent.fwResources or noTbl, ntable.haveResources, true)
		syncupTables(ent.fwResourcesStatic or noTbl, ntable.haveResources, true) -- no delete since it gets merged with the rest of 'have resources'
	end

end

local Entity = FindMetaTable('Entity')
--
-- Pass it the typeid of the resource and the amount to use
--
function Entity:ConsumeResource(type, amount)
	if not self.fwNetwork or not self.fwResourcesStatic then
		error("[ent] No resource network")
	end

	-- validate that there is storage available and there is something in the table
	local storage = self.fwNetwork.storage[type]
	if not storage then
		self.fwResourcesStatic[type] = 0
		return false, 0
	end
	local currentStore, available = next(storage, nil) -- this check might not be necessary but it is robust
	if not currentStore then
		self.fwResourcesStatic[type] = 0
		return false, 0
	end

	local desiredAmount = amount -- the original amount

	for currentStore, available in pairs(storage) do
		if IsValid(currentStore) then
			if available >= amount then
				currentStore.Storage[type] = currentStore.Storage[type] - amount
				storage[currentStore] = storage[currentStore] - amount
				if storage[currentStore] == 0 then
					storage[currentStore] = nil
				end

				amount = 0
				break
			else
				amount = amount - available
				currentStore.Storage[type] = 0
				storage[currentStore] = nil
			end
		end
	end

	self.fwResourcesStatic[type] = desiredAmount - amount

	if amount == 0 then
		return true, desiredAmount
	else
		return false, desiredAmount - amount
	end
end

--
-- CONSTRUCT TIMERS
--
timer.Create('fw.resourceNetwork.update', fw.config.resourceNetworkUpdateInterval, 0, function()
	fw.resource.updateNetworks()
end)
