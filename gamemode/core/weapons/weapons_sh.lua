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
	},
	rpm = {
		function(self)
			self.Primary.RPM = self.Primary.RPM * 1.15
		end,
		"15% increased rate of fire"
	},
	spread = {
		function(self)
			self.Primary.BaseSpread = self.Primary.BaseSpread * 0.9
		end,
		"10% decreased spread"
	},
	recoil = {
		function(self)
			self.Primary.BaseRecoil = self.Primary.BaseRecoil * 0.85
			self.Primary.MaxRecoil = self.Primary.MaxRecoil * 0.9
		end,
		"15% decreased recoil"
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
