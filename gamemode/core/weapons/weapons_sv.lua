fw.weapons.deadDoors = {}

fw.hook.Add("PlayerSwitchWeapon", "SetPhysgunColor", function(ply, _, newWep)
	if (fw.config.physgunColorFactionColor) then
		if (newWep:GetClass() == "weapon_physgun") then
			local col = fw.team.factions[ply:getFaction()].color
			local r, g, b = col.r / 255, col.g / 255, col.b / 255
			ply:SetWeaponColor(Vector(r, g, b))
		end
	end
end)

fw.hook.Add("EntityTakeDamage", "FuckDoors", function(ent, dmg)
	if ent:GetClass() == "prop_door_rotating" and dmg:GetAmmoType()	== 7 and dmg:GetAttacker():GetShootPos():Distance(dmg:GetDamagePosition()) < 250 then
		fw.weapons.deadDoors[ent:GetPos()] = {ent:GetAngles(), ent:GetSkin(), ent:GetModel(), CurTime() + fw.config.doorRespawnTime}

		local prop = ents.Create("prop_physics")
		prop:SetPos(ent:GetPos())
		prop:SetSkin(ent:GetSkin())
		prop:SetAngles(ent:GetAngles())
		prop:SetModel(ent:GetModel())
		prop:SetBodyGroups("01")
		prop:Spawn()

		ent:Remove()

		local phys = prop:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:ApplyForceOffset(dmg:GetDamageForce(), dmg:GetDamagePosition())
			local mass = phys:GetMass()
			local health = math.Round(mass * 10)

			ndoc.table.fwProps[prop:EntIndex()] = {}
			ndoc.table.fwProps[prop:EntIndex()].health = health
			ndoc.table.fwProps[prop:EntIndex()].maxhealth = health
		end
	end
end)

fw.hook.Add("DoPlayerDeath", "DropGunsOnDeath", function(ply)
	if IsValid(ply:GetActiveWeapon()) and not fw.config.dropBlacklist[ply:GetActiveWeapon():GetClass()] then
		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
			filter = function(ent) if ent != ply then return true end end
		})

		local ent = ents.Create("fw_gun")
		ent:setWeapon(ply)
		ent:SetPos(tr.HitPos)
		ent:Spawn()
	end
end)

timer.Create("DoorSpawner", 5, 0, function()
	for k,v in pairs(fw.weapons.deadDoors) do
		if v and v[4] < CurTime() then
			local door = ents.Create("prop_door_rotating")
			door:SetPos(k)
			door:SetAngles(v[1])
			door:SetModel(v[3])
			door:SetSkin(v[2])
			door:SetKeyValue("hardware", 1)
			door:Spawn()
			fw.weapons.deadDoors[k] = false
		end
	end
end)

-- Credit to Nak
local dmgmultiply = {}
    dmgmultiply[HITGROUP_HEAD] = 4
    dmgmultiply[HITGROUP_CHEST] = 1
    dmgmultiply[HITGROUP_STOMACH] = 1.25
    dmgmultiply[HITGROUP_LEFTARM] = 1
    dmgmultiply[HITGROUP_RIGHTARM] = 1
    dmgmultiply[HITGROUP_LEFTLEG] = 0.75
    dmgmultiply[HITGROUP_RIGHTLEG] = 0.75
    dmgmultiply[HITGROUP_GENERIC] = 0.75
    dmgmultiply[HITGROUP_GEAR] = 0.75 -- Belt or something .. not on every model

fw.hook.Add("ScalePlayerDamage","DamageControl",function(ply,hitgroup,dmginfo)
    local multi = dmgmultiply[hitgroup or 0] or dmgmultiply[HITGROUP_GENERIC] or 1
    dmginfo:ScaleDamage( multi )
end)
