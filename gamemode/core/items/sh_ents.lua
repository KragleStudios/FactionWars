fw.ents.item_list = {}
fw.ents.shipment_list = {}
fw.ents.weapon_list = {}

function fw.ents.registerItem(name, tbl)
	assert(type(name) == "string", "must provide a string name when registering an item")
	assert(tbl.model, "tbl.model must provide a world model for " .. name)
	assert(tbl.entity, "tbl.entity must provide an entity class to spawn for " .. name)
	assert(type(tbl.price) == "number", "tbl.price must provide price for "..name)
	assert(type(tbl.max) == "number", "tbl.max must provide a maximum item count for " .. name)

	tbl.name = name
	tbl.stringID = tbl.stringID or tbl.entity

	tbl.index = table.insert(fw.ents.item_list, tbl)
	tbl.category = tbl.category or "Things and Stuff"
	tbl.command = 'fw_item_'..(tbl.entity)
	if tbl.job then tbl.jobs = {tbl.job} end
	if tbl.faction then tbl.factions = {tbl.faction} end

	tbl.shouldDisplay = function(self, player)
		if self.jobs and not table.HasValue(self.jobs, player:Team()) then return false, "You do not have the corret job to buy this" end
		if self.factions and not table.HasValue(self.factions, player:getFaction()) then return false, "You are not in the correct faction to buy this" end
		if tbl.customShouldDisplay then
			return tbl:customShouldDisplay(player)
		end
		return true
	end

	tbl.canBuy = function(self, player)
		local shouldDisplay, message = self:shouldDisplay(player)
		if shouldDisplay == false then return false, message end
		if self.max > 0 and self:getPlayerOwnedCount(player) >= self.max then return false, name .. " max item limit is " .. self.max end
		if not player:canAfford(self.price) then return false, "You can not afford $" .. self.price end
		if tbl.customCanBuy then
			return tbl:customCanBuy(player)
		end
		return true
	end

	tbl.getPlayerOwnedCount = function(self, player)
		local count = 0
		for k,v in ipairs(ents.FindByClass(tbl.entity)) do
			if v:FWGetOwner() == player then
				count = count + 1
			end
		end
		return count
	end

	if SERVER then
		concommand.Add(tbl.command, function(pl)
			local shouldBuy, message = tbl:canBuy(pl)
			if not shouldBuy then
				pl:FWChatPrintError(message)
				return
			end

			pl:addMoney(-tbl.price)

			fw.ents.createItem(pl, tbl)
		end)
	end
end

function fw.ents.registerWeapon(name, tbl)
	assert(type(name) == "string", "must provide a string name when registering a weapon")
	assert(tbl.model, "tbl.model must provide a world model for " .. name)
	assert(tbl.weapon, "tbl.weapon must provide an weapon class to spawn for " .. name)
	assert(type(tbl.price) == "number", "tbl.price must provide price for "..name)
	assert(type(tbl.weapon) == "string", "tbl.weapon must specify the class of the weapon to spawn for "..name)

	tbl.name = name

	tbl.shouldDisplay = function(self, player)
		if self.jobs and not table.HasValue(self.jobs, player:Team()) then return false, "You do not have the corret job to buy this" end
		if self.factions and not table.HasValue(self.factions, player:getFaction()) then return false, "You are not in the correct faction to buy this" end
		if tbl.customShouldDisplay then
			return tbl:customShouldDisplay(player)
		end
		return true
	end

	tbl.canBuy = function(self, player)
		local shouldDisplay, message = self:shouldDisplay(player)
		if shouldDisplay == false then return false, message end
		if not player:canAfford(self.price) then return false, "You can not afford $" .. self.price end
		if tbl.customCanBuy then
			return tbl:customCanBuy(player)
		end
		return true
	end

	if tbl.shipment or tbl.both then
		tbl.shipmentCount = tbl.shipmentCount or fw.config.defaultShipmentCount

		local shipment = table.Copy(tbl)
		shipment.category = shipment.category or 'Things and Stuff'
		shipment.price = tbl.shipmentPrice or tbl.price * tbl.shipmentCount * fw.config.shipmentMarkdown
		shipment.command = (tbl.command or tbl.weapon) .. '_shipment'
		shipment.index = table.insert(fw.ents.shipment_list, shipment)

		if SERVER then
			concommand.Add(shipment.command, function(pl)
				local shouldBuy, message = tbl:canBuy(pl)
				if not shouldBuy then
					pl:FWChatPrintError(message)
					return
				end
				pl:addMoney(-shipment.price)

				fw.ents.createShipment(pl, shipment)
			end)
		end
	end
	if tbl.single or tbl.both then
		local single = table.Copy(tbl)
		single.category = single.category or 'Things and Stuff'
		single.command = (tbl.command or tbl.weapon) .. '_single'
		single.index = table.insert(fw.ents.weapon_list, single)

		if SERVER then
			concommand.Add(single.command, function(pl)
				local shouldBuy, message = tbl:canBuy(pl)
				if not shouldBuy then
					pl:FWChatPrintError(message)
					return
				end
				pl:addMoney(-single.price)

				fw.ents.createWeapon(pl, single)
			end)
		end
	end
end
