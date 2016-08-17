fw.data.addPersistField("?.inventory.slots")
util.AddNetworkString("fw.dropItem")

local invItemID = 1

function fw.inv.canRemoveItem(ply, item)
	if (item.jobs and not table.HasValue(item.jobs, ply:Team())) then return false, "wrong team" end
	if (item.factions and not table.HasValue(item.factions, ply:getFaction())) then return false, "wrong faction" end
	
	return true
end

function fw.inv.getItemByInvID(ply, id)
	local slots = ndoc.table.items[ply].inventory.slots
	local item, position

	id = tonumber(id)

	for k,v in ndoc.pairs(slots) do
		if (tonumber(v.invID) == id) then 
			position = k
			item = v 

			break 
		end
	end

	return item, position
end

net.Receive("fw.dropItem", function(_, ply)
	local itemIndex = net.ReadInt(32)
	local invID     = net.ReadInt(32)

	local inv = ndoc.table.items[ply].inventory
	local item = fw.ents.item_list[itemIndex]
	local name = "Name not found :("

	if (not item) then return end
	local canRemove, msg = fw.inv.canRemoveItem(ply, item)

	if (msg) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
		return
	end

	local class = item.shipment and "fw_shipment" or item.entity
	local it, pos = fw.inv.getItemByInvID(ply, invID)

	local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace).HitPos

	local ent = ents.Create(class)
	ent:SetPos(tr)
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(ply)
	ent.stringID = item.stringID
	if (item.shipment) then
		ent:setEntityModel(item.model)
		ent:setEntity(item.entity)
		ent:setShipmentAmount(ndoc.table.items[ply].inventory.slots[pos].remaining)
		ent:setName(name)
	end

	fw.inv.removeItem(ply, pos)
end)

--[[
	Inventory tree structure:
	ndoc.table
		Player
			Inventory
				Slots = {item data}
				slotCount = int available slots for the player
]]


function fw.inv.calcInvSpot(ply)
	local slotCount = ndoc.table.items[ply].inventory.slotCount or fw.config.defaultInvSlots
	local slots     = ndoc.table.items[ply].inventory.slots

	local count = 0
	for k,v in ndoc.pairs(ndoc.table.items[ply].inventory.slots) do
		count = count + 1
	end

	return (count != slotCount) and count + 1 or nil
end

--removes the value from the player's inv and shifts all other values up :D
function fw.inv.removeItem(ply, position)
	for k,v in ndoc.pairs(ndoc.table.items[ply].inventory.slots) do
		if (k == position) then
			ndoc.table.items[ply].inventory.slots[position] = nil --remove the value
		end
		if (k > position) then
			local new_index = k - 1
			local data = ndoc.table.items[ply].inventory.slots[k]
			local newData = data.remaining and {itemIndex = data.itemIndex, invID = data.invID, remaining = data.remaining} or {itemIndex = data.itemIndex, invID = data.invID} --reconstrct the table since we can't directly copy from netdoc

			ndoc.table.items[ply].inventory.slots[new_index] = newData --shift it up a value
			ndoc.table.items[ply].inventory.slots[k] = nil --remove the value
		end
	end
end

function fw.inv.addItem(ply, ent)
	if (not IsValid(ent)) then return end

	local item, index
	local isShipment = ent:GetClass() == "fw_shipment"
	for k,v in pairs(fw.ents.item_list) do
		if v.shipment and isShipment and (ent:GetEnt() == v.entity) then
			item = v
			index = k
		elseif (v.entity == ent:GetClass() and not v.shipment) then
			item = v
			index = k
		end
	end

	if (not item) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end
	if (not item.storable) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end


	local slot = fw.inv.calcInvSpot(ply)
	if (not slot) then ply:FWChatPrintError("Your inventory is full!") return end

	local data = item.shipment and {itemIndex = index, invID = invItemID, remaining = ent:GetRemaining()} or {itemIndex = index, invID = invItemID}
	ndoc.table.items[ply].inventory.slots[slot] = data

	ent:Remove()

	invItemID = invItemID + 1
end

local dis = 50
fw.hook.Add("KeyPress", "Pickup items", function(ply, key)
	if (key == IN_SPEED) then
		local tr = ply:GetEyeTrace()
		if (tr.Hit and tr.Entity and ply:EyePos():DistToSqr(tr.HitPos) <= dis * dis) then
			fw.inv.addItem(ply, tr.Entity)
		end

		ply.in_shift = false
	end
end)

fw.hook.Add("KeyRelease", "Pickup Items Release", function(ply, key)
	if (key == IN_SPEED) then
		ply.in_shift = false
	end
end)

fw.hook.Add("PlayerCanPickupWeapon", "StopAutoTouching", function(ply, key)
	if (ply:KeyDown(IN_USE)) then return true end

	return false
end)

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("PlayerInitialSpawn", "LoadItems", function(ply)
	ndoc.table.items[ply] = ndoc.table.items[ply] or {}
	ndoc.table.items[ply].inventory = ndoc.table.items[ply].inventory or {slots = {}, slotCount = fw.config.defaultInvSlots}
end)

fw.hook.Add("PlayerDisconnected", "RemoveSpareItems", function(ply)
	local ownedItems = ndoc.table.items[ply].inventory

	--if the player rejoined cancel removing their things and reset to before they left
	timer.Simple(120, function()
		for k,v in pairs(player.GetAll()) do
			if (v:SteamID() == id) then
				ndoc.table.items[v].inventory = ownedItems

				return
			end
		end

		for k,v in pairs(ents.GetAll()) do
			if (v.owner and (v.owner == ply) and (v.stringID and fw.ents.item_list[v.stringID].removeOnDisc)) then
				v:Remove()
			end
		end
	end)
end)

fw.hook.Add("FWItemRegistered", "AddCMDS", function(tbl)
	if (tbl.weapon) then
		concommand.Add(tbl.command.."_equip", function(ply, cmd, args)
			if (not tbl.shipment) then				
				local invItemID = args[1]
				local item, position = fw.inv.getItemByInvID(ply, invItemID)

				local canRemove, msg = fw.inv.canRemoveItem(ply, item)

				if (msg) then 
					ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
					return
				end

				fw.inv.removeItem(ply, position)
				ply:Give(tbl.entity)
			end
		end)
	end

	if (tbl.useable) then
		concommand.Add(tbl.command.."_use", function(ply, cmd, args)
			if (not tbl.shipment) then				
				local invItemID = args[1]
				local item, position = fw.inv.getItemByInvID(ply, invItemID)

				local canRemove, msg = fw.inv.canRemoveItem(ply, item)

				if (msg) then 
					ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
					return
				end

				fw.inv.removeItem(ply, position)
				ply:Give(tbl.entity)
			end
		end)
	end
end)