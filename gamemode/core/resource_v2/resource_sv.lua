local fw = fw

--
-- RESOURCE ENTITIES
--
local resource_entities = fw.resource.resource_entities

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
				root1 = temp
			end
			union_find[root2] = root1
			union_find_counts[root1] = union_find_counts[root1] + union_find_counts[root2]
			union_find_counts[root2] = nil
		end

		for k, ent1 in pairs(resource_entities) do
			for k, ent2 in pairs(resource_entities) do
        -- TODO: thelastpenguin implement a kdtree
				if ent1:GetPos():DistToSqr(ent2:GetPos()) < (ent1.NETWORK_SIZE or 200) then
					union(ent1, ent2)
				end
			end
		end

		for k, ent in ipairs(resource_entities) do
			local r = root(ent)
			local groupId = r:EntIndex()
			if not networks[groupId] then
				networks[groupId] = {
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
		print("processing network")

		local total_consumption = setmetatable({}, autozero_mt)
		local total_production = setmetatable({}, autozero_mt)
		local total_storage = setmetatable({}, autozero_mt)

		local availableProduction = setmetatable({}, autotable_mt)
		local desiredConsumption = setmetatable({}, autotable_mt)
		local availableStorage = setmetatable({}, autotable_mt)

		-- compute available resources
		for k, ent in ipairs(network.ents) do
			if ent.ConsumesResources then
				print ("entity consumes resources!")
				for type, amount in ipairs(ent.ConsumesResources) do
					if resTypes[type] then
						total_consumpiton[type] = total_consumption[type] + amount
						availableProduction[type][ent] = amount
					end
				end
			end

			if ent.GeneratesResources then
				for type, amount in ipairs(ent.GeneratesResources) do
					if resTypes[type] then
						total_consumpiton[type] = total_consumption[type] + amount
						desiredConsumption[type][ent] = amount
					end
				end
			end

			if ent.Storage then
				for type, amount in ipairs(ent.CurrentStorage) do
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
		network.consumers = availableConsumption
		network.storage = availableStorage

		-- clear networking for resources that are no longer available
		for k, ent in ipairs(network.ents) do
			print("set ent.fwNetwork", ent)
			ent.fwNetwork = network
			for type, _ in pairs(ent.fwResources) do
				ent.fwResources[type] = nil
			end
		end

		-- update networking with new and improved values
		for type, producers in pairs(availableProduction) do
			local consumers = desiredConsumption[type]
			if consumers then
				local currentProducer, canProduce = next(producers, nil)

				for ent, wanted in pairs(consumers) do
					local amount = wanted
					repeat
						if canProduce < amount then
							amount = amount - canProduce
							currentProducer, canProduce = next(producers, currentProducer)
						else
							canProduce = canProduce - amount
							amount = 0
						end
					until amount == 0 or not currentProducer

					if amount == 0 then
						consumers[ent] = nil
					else
						consumers[ent] = amount
						break
					end

					ent.fwResources[type] = wanted - amount
				end
			end
		end
	end
	PrintTable(networks)
end

local Entity = FindMetaTable('Entity')
--
-- Pass it the typeid of the resource and the amount to use
--
function Entity:ConsumeResource(type, amount)
	if not self.fwNetwork or not self.fwConsumption then
		error("[ent] No resource network")
	end

	local desiredAmount = amount -- the original amount

	local storage = self.fwNetwork.producers[type]

	if not storage then return false, 0 end
	local currentStore, available = next(storage, nil)
	if not currentStore then return false, 0 end

	repeat
		if available < amount then
			amount = amount - available
			currentStore.CurrentStorage[type] = 0
			storage[type][currentStore] = nil
			currentStore, available = next(storage, currentStore)
		else
			currentStore.CurrentStorage[type] = currentStore.CurrentStorage[type] - amount
			amount = 0
		end
	until amount == 0 or not currentStore

	self.fwConsumption[type] = desiredAmount - amount

	if amount == 0 then
		return true, desiredAmount
	else
		return false, desiredAmount - amount
	end
end

--
-- Pass it the typeid of the resource
--
function Entity:GetResourceLevel(type)
	if not self.fwResources then
		error '[ent] no resource network'
	end
	return self.fwResources[type]
end

--
-- CONSTRUCT TIMERS
--
timer.Create('fw.resourceNetwork.update', fw.config.resourceNetworkUpdateInterval, 0, function()
	fw.resource.updateNetworks()
end)


--
-- NETWORKING RESOURCE INFORMATION
--
local net_WriteUInt = net.WriteUInt
util.AddNetworkString('fw.resource.getInfo')
net.Receive('fw.resource.getInfo', function(_, pl)
	local types = fw.resource.types

	local ent = net.ReadEntity()
	if not ent.fwResources or not ent.fwNetwork then return end

	net_WriteUInt(#ent.fwNetwork.ents, 12)

	-- confusingish binary networking! yay
	local function helpWriteStatistics(table)
		for type, statistic in pairs(table) do
			local id = types[type].id
			net_WriteUInt(id, 8)
			net_WriteUInt(statistic, 24)
		end
		net_WriteUInt(0, 8) -- the 0 id signals networking is over
	end

	-- write the statistics tables!
	net.Start('fw.resource.getInfo')
		helpWriteStatistics(ent.fwNetwork.totalProduction)
		helpWriteStatistics(ent.fwNetwork.totalConsumption)
		helpWriteStatistics(ent.fwNetwork.totalStorage)
		helpWriteStatistics(ent.fwConsumption)
		helpWriteStatistics(ent.fwResources)
	net.Send(pl)
end)
