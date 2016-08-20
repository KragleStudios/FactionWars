util.AddNetworkString("playerBuyItem")

ndoc.table.items = {}

function fw.ents.buyItem(ply, item_index)
	local canjoin, msg = fw.ents.canPlayerBuyItem(ply, item_index)

	if (msg) then
		ply:FWChatPrintError(msg)
		return
	end
	local item = fw.ents.item_list[item_index]
	ply.maxItems[item.entity] = ply.maxItems[item.entity] and ply.maxItems[item.entity] + 1 or 1

	item:onBuy(ply)

	ply:addMoney(-item.price)
end

function fw.ents.createShipment(item)
	local ship = ents.Create("fw_shipment")
	ship:SetPos(tr)
	ship:SetItem(item.index)
	ship:Spawn()
	ship:Activate()
	ship:FWSetOwner(ply)

	fw.ents.setPositionWithEntityTrace(ship)
end

function fw.ents.createItem(pl, item)
	local ent = ents.Create(item.entity)
	ent:Spawn()
	ent:Activate()
	ent:FWSetOwner(pl)

	fw.ents.setPositionWithEntityTrace(pl, ent)
end

function fw.ents.createWeapon(pl, item)
	local ent = ents.Create("fw_gun")
	ent:Spawn()
	ent:Activate()
	ent:SetWeaponAndModel(item.weapon, item.model)
	ent:FWSetOwner(pl)

	if item.buff then
		ent:SetBuff(item.buff)
	end

	fw.ents.setPositionWithEntityTrace(pl, ent)
end

function fw.ents.setPositionWithEntityTrace(pl, ent)
	local tr = util.TraceEntity({
		start = pl:EyePos(),
		endpos = pl:EyePos() +  pl:GetAimVector() * 100,
		filter = function() return false end
	})

	ent:SetPos(tr.HitPos)
end


fw.hook.Add("EntityRemoved", "AdjustItemCount", function(ent)
	local own = ent:FWGetOwner()
	local class = ent:GetClass()

	if (IsValid(own) and class != "prop_physics" and own and own.maxItems[class]) then
		own.maxItems[class] = own.maxItems[class] and own.maxItems[class] - 1 or nil
	end
end)
