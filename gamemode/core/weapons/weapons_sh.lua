fw.weapons.weapons = {}

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