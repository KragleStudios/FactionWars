local Networks = {}
Networks.EntNodes = {}

fw.include_sv "sv_network_entity.lua"

function Networks.GetNetworks()
	return Networks
end

function Networks.OnEntityCreated(ent) -- TODO: Ensure that everytime something changes within the network, all the entities are updated.
	if IsValid(ent) then
		if Networks.EntNodes[ent:GetClass()] then
			timer.Simple(0, function() -- Need to wait a tick because entity hasnt actually been created yet :(
				Networks.CreateNetwork(ent, ent:GetNetworkRadius())
			end)
		end
	end
end
hook.Add("OnEntityCreated", "CreateEntityNetwork", Networks.OnEntityCreated)

function Networks.OnEntityRemoved(ent)
	if ent:IsNode() then
		print("Removed: " .. tostring(ent))
		ent.net:Remove()
		timer.Simple(0, function() -- Need to wait a tick because the entity hasnt actually been removed yet
			Networks.CheckSubnets()
		end)
	elseif ent.connectednet != nil then -- Its a entity connected to a network
		local netwrk = ent.connectednet -- save it for next frame to we can still find it
		timer.Simple(0, function()
			netwrk:Update()
		end)
	end
end
hook.Add("EntityRemoved", "RemoveEntityNetwork", Networks.OnEntityRemoved)

function Networks.HandleEntPickup(ply, ent)
	print(ply, ent, "You picked it up!")
	if ent:IsNode() then
		ent.net:SetEnable(false)
		for k,v in pairs(ent.net.subnets) do
			v.net.subnets[ent.net:GetID()] = nil -- any connections are removed, maybe put this inside network:Clear()?
		end
		ent.net:Clear() -- We've disabled it so lets clear all its subnets so it cant be used while we're moving it
	end
end
hook.Add("GravGunOnPickedUp", "EntityNetworkPickedUp", Networks.HandleEntPickup)

function Networks.HandleEntDrop(ply, ent)
	print(ply, ent, "You dropped it!")
	if ent:IsNode() then
		ent.net:SetEnable(true)
		ent.net:SetPos(ent:GetPos()) -- Need to update the position once it is dropped..
		ent.net:Update()
	elseif ent.connectednet != nil then
		ent.connectednet:CheckReceivers()
	elseif ent.GenerationRequirements != nil then
		ent:ConnectToNet()
	end
end
hook.Add("GravGunOnDropped", "EntityNetworkDropped", Networks.HandleEntDrop)

function Networks.GenerateTick()

end


function Networks.RegisterEntityNode(class, b)
	Networks.EntNodes[class] = (b or true)
end

function Networks.CreateNetwork(ent, radius)
	local netwrk = Networks.network.create(ent, radius)

	return netwrk
end

function Networks.CheckSubnets()
	for k,v in pairs(Networks.network.networks) do
		print(v, v:GetID() or "#error")
		v:CheckNetValidity()
	end
end


return Networks
