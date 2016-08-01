local entity = FindMetaTable("Entity")

function entity:getHealth()
	return (ndoc.table.fwProps[self:EntIndex()] or {}).health
end

function entity:getMaxHealth()
	return (ndoc.table.fwProps[self:EntIndex()] or {}).maxhealth
end

if (SERVER) then
	ndoc.table.fwProps = {}

	function entity:setHealth(amt)
		ndoc.table.fwProps[self:EntIndex()].health = amt
	end

	fw.hook.Add("PlayerSpawnedProp", "PropHealthInitiate", function(ply, mdl, ent)
		local phsObj = ent:GetPhysicsObject()
		if (not IsValid(phsObj)) then return end

		local mass = phsObj:GetMass()
		local health = math.Round(mass * 10)

		ndoc.table.fwProps[ent:EntIndex()] = {}
		ndoc.table.fwProps[ent:EntIndex()].health = health
		ndoc.table.fwProps[ent:EntIndex()].maxhealth = health

		if ply:canAfford(math.floor(mass / 10)) then
			ply:addMoney(-math.floor(mass / 10))
		else
			ent:Remove()
			ply:FWChatPrint("You cannot afford to spawn this prop!")
			return
		end

		ent:setHealth(health)
		--ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		--ent:SetColor(Color(255, 255, 255, 180))
		--ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end)

	fw.hook.Add("EntityRemoved", "EntityIsDeleted", function(ent)
		if (ent:GetClass() ~= "prop_physics") then return end

		ndoc.table.fwProps[ent:EntIndex()] = nil
	end)

	fw.hook.Add("EntityTakeDamage", "PropHealthDepreciate", function(ent, info)
		if (ent:GetClass() ~= "prop_physics" or not IsValid(ent)) then return end
		if (not ndoc.table.fwProps[ent:EntIndex()]) then return end --stupport for stuff

		local dmg = info:GetDamage()
		local health = ent:getHealth()
		local new_health = math.Round(health - dmg)
		if (math.Round(new_health) <= 0) then
			local data = EffectData()
			data:SetOrigin(ent:GetPos())

			util.Effect("Explosion", data)
			ent:Remove()
		else
			ndoc.table.fwProps[ent:EntIndex()].health = new_health
		end
	end)
end
