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
	end)

	fw.hook.Add("EntityRemoved", "EntityIsDeleted", function(ent)
		if (ent:GetClass() != "prop_physics") then return end
		
		ndoc.table.fwProps[ent:EntIndex()] = nil
	end)

	fw.hook.Add("EntityTakeDamage", "PropHealthDepreciate", function(ent, info)
		if (ent:GetClass() != "prop_physics" or not IsValid(ent)) then return end
		if (not ndoc.table.fwProps[ent:EntIndex()]) then return end --stupport for stuff
		
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

		if (IsValid(hit.Entity) and hit.Entity:GetClass() == "prop_physics" and (hit.HitPos:DistToSqr(LocalPlayer():GetPos()) < (100 * 100))) then
			draw.SimpleText("Health: ".. tostring(hit.Entity:getHealth()), fw.fonts.default:atSize(18), ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end


