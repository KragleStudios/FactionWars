fw.weapons.weapons = {}
fw.weapons.buffs = {
	damage = {
		function(self)
			self.Primary.Damage = self.Primary.Damage * 1.2
		end,
		"20% increased damage"
	},
	ammo = {
		function(self)
			self.Primary.ClipSize = self.Primary.ClipSize * 1.2
		end,
		"20% increased ammo capacity",
	}
}

function fw.weapons.createGun(name, config, entity)
	assert(entity, "gun entity name not provided")
	config.Name = name
	config.PrintName = name
	config.Spawnable = true
	fw.weapons.weapons[entity] = config
end

fw.hook.Add("Initialize", "LoadWeapons", function()
	for e,w in pairs(fw.weapons.weapons) do
		local gun = weapons.Get("fw_gun_base")
		for k,v in pairs(w) do
			gun[k] = v
		end

		weapons.Register(gun, e)
	end
end)

if (SERVER) then
	fw.hook.Add("PlayerSwitchWeapon", "SetPhysgunColor", function(ply, _, newWep)
		if (fw.config.physgunColorFactionColor) then
			if (newWep:GetClass() == "weapon_physgun") then
				local col = fw.team.factions[ply:getFaction()].color
				local r, g, b = col.r / 255, col.g / 255, col.b / 255

				ply:SetWeaponColor(Vector(r, g, b))
			end
		end
	end)
end