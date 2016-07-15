local entity = FindMetaTable("Entity")

function entity:getHealth()
	return ndoc.table.fwProps[self:EntIndex()].health
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
	end)

	fw.hook.Add("EntityRemoved", "EntityIsDeleted", function(ent)
		if (ent:GetClass() != "prop_physics") then return end
		
		ndoc.table.fwProps[ent:EntIndex()] = nil
	end)

	fw.hook.Add("EntityTakeDamage", "PropHealthDepreciate", function(ent, info)
		if (ent:GetClass() != "prop_physics" or not IsValid(ent)) then return end
		
		local dmg = info:GetDamage()

		local health = ent:getHealth()
		local new_health = health - dmg
		if (new_health < 0) then
			local data = EffectData()
			data:SetOrigin(ent:GetPos())

			util.Effect("Explosion", data)
			ent:Remove()
		else
			ndoc.table.fwProps[ent:EntIndex()].health = new_health
		end
	end)
else
	fw.hook.Add("HUDPaint", "ShowPropHealth", function()
		local hit = LocalPlayer():GetEyeTrace()

		if (hit.Entity and hit.Entity:GetClass() == "prop_physics" and (hit.HitPos:DistToSqr(LocalPlayer():GetPos()) < (100 * 100))) then
			local health = ndoc.table.fwProps[hit.Entity:EntIndex()].health

			draw.SimpleText("Health: ".. health, "Default", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end


