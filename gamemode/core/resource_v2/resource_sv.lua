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
				if ent1:GetPos():DistToSqr(ent2:GetPos()) < ent.NETWORK_SIZE then
					union(ent1, ent2)
				end
			end
		end

		for k,ent in ipairs(resource_entities) do
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
		local total_consumption = setmetatable({}, autozero_mt)
		local total_production = setmetatable({}, autozero_mt)
		local total_storage = setmetatable({}, autozero_mt)

		local availableProduction = setmetatable({}, autotable_mt)
		local desiredConsumption = setmetatable({}, autotable_mt)
		local availableStorage = setmetatable({}, autotable_mt)

		-- compute available resources
		for k, ent in ipairs(network.ents) do

			if ent.ConsumesResources then
				for type, amount in ipairs(ent.ConsumesResources) do
					total_consumpiton[type] = total_consumption[type] + amount
					availableProduction[type][ent] = amount
				end
			end

			if ent.GeneratesResources then
				for type, amount in ipairs(ent.GeneratesResources) do
					total_consumpiton[type] = total_consumption[type] + amount
					desiredConsumption[type][ent] = amount
				end
			end

			if ent.Storage then
				for type, amount in ipairs(ent.Storage) do
					total_storage[type] = total_storage[type] + amount
					availableStorage[type][ent] = amount
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
		for k, ent in ipairs(network) do
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

	-- TODO thelastpenguin implement storage
end
