local entity = FindMetaTable("Entity")

function entity:getHealth()
	return ndoc.table.fwProps[self].health
end


if (SERVER) then
	ndoc.table.fwProps = {}

	function entity:setHealth(amt)
		ndoc.table.fwProps[self].health = amt
	end

	fw.hook.Add("PlayerSpawnedProp", "PropHealthInitiate", function(ply, mdl, ent)
		local phsObj = ent:GetPhysicsObject()
		if (not IsValid(phsObj)) then return end

		local mass = phsObj:GetMass()
		local health = mass * 10

		print(ent)

		ndoc.table.fwProps[ent] = {}
		ndoc.table.fwProps[ent].health = health
	end)

	fw.hook.Add("EntityTakeDamage", "PropHealthDepreciate", function(ent, info)
		if (ent:GetClass() != "prop_physics" or not IsValid(ent)) then return end
		
		local dmg = info:GetDamage()

		local health = ent:getHealth()
		local new_health = health - dmg
		if (new_health < 0) then
			local data = EffectData():SetOrigin(ent:GetPos())

			ent:Remove()

			util.Effect("Explosion", data)
		else
			ndoc.table.fwProps[ent].health = new_health
		end
	end)
else
	fw.hook.Add("HUDPaint", "ShowPropHealth", function()
		local hit = LocalPlayer():GetEyeTrace()

		if (hit.Entity and hit.Entity:GetClass() == "prop_physics" and (hit.HitPos:DistToSqr(LocalPlayer():GetPos()) < (100 * 100))) then
			local health = ndoc.table.fwProps[hit.Entity].health

			draw.SimpleText(health,"Default",ScrW() / 2,ScrH() / 2,Color(255, 255, 255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end


