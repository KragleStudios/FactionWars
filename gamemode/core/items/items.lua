fw.ents.registerItem("Tier 1 Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier1",
	price = 1500,
	category = "Printers",
	max = 8,
})

fw.ents.registerItem("Tier 2 Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier2",
	price = 3000,
	category = "Printers",
	max = 4,
})

fw.ents.registerItem("Tier 3 Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier3",
	price = 5000,
	category = "Printers",
	max = 4,
})

fw.ents.registerItem("Tier 4 Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier4",
	price = 12500,
	category = "Printers",
	max = 2
})

fw.ents.registerItem("Tier 5 Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier5",
	price = 25000,
	category = "Printers",
	max = 2,
})

fw.ents.registerItem("Titan Money Printer", {
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_titan",
	price = 40000,
	category = "Printers",
	max = 1,
})

fw.ents.registerItem("Printer Paper", {
	model = "models/props_junk/cardboard_box003a.mdl",
	entity = "fw_paper",
	price = 100,
	category = "Resources",
	max = 25,
})

fw.ents.registerItem("Gas Cansiter", {
	model = "models/props_junk/gascan001a.mdl",
	entity = "fw_gas_medium",
	category = "Resources",
	price = 100,
	max = 20,
})

fw.ents.registerItem("Water Tank", {
	model = "models/props_borealis/bluebarrel001.mdl",
	entity = "fw_water_large",
	category = "Resources",
	price = 120,
	max = 20,
})

---
--- BEGIN OTHER WEAPON REGISTRATION
---
fw.ents.registerItem("Turret", {
	model = "models/combine_turrets/ground_turret.mdl",
	entity = "fw_turret",
	price = 15000,
	category = "Defense",
	factions = {FACTION_GANGA, FACTION_GANGB, FACTION_POLICE},
	max = 20,
})

fw.ents.registerItem("Radar", {
	model = "",
	entity = "fw_radar",
	price = 1500,
	category = "Defense",
	factions = {FACTION_GANGA, FACTION_GANGB, FACTION_POLICE},
	max = 5,
})

---
--- BEGIN RESOURCE REGISTRATION
---

fw.ents.registerItem("Generator", {
	model = "models/props_vehicles/generatortrailer01.mdl",
	entity = "fw_generator",
	price = 2000,
	max = 20,
})

fw.ents.registerItem("Health Machine", {
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_healthmachine",
	price = 1000,
	max = 10,
})

fw.ents.registerItem("Armour Machine", {
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_armourmachine",
	price = 1000,
	max = 10,
})

fw.ents.registerItem("Respawn Point", {
	model = "",
	entity = "fw_respawn_point",
	price = 100,
	max = 10,
})

fw.ents.registerItem("Mineral Extractor", {
	model = "models/props_combine/combinethumper002.mdl",
	entity = "fw_mineral_extractor",
	price = 5000,
	max = 5,
})

fw.ents.registerItem("Fermentation Tank", {
	model = "models/props_wasteland/laundry_basket001.mdl",
	entity = "fw_fermentation_tank",
	price = 500,
	max = 10,
})

fw.ents.registerItem("Distillery", {
	model = "models/props_c17/FurnitureBoiler001a.mdl",
	entity = "fw_distillery",
	price = 900,
	max = 5,
})

fw.ents.registerItem("Meth Lab", {
	model = "models/props_lab/crematorcase.mdl",
	entity = "fw_methlab",
	price = 1600,
	max = 5,
})

fw.ents.registerItem("Oil Extractor", {
	model = "models/props_wasteland/gaspump001a.mdl",
	entity = "fw_oil_extractor",
	price = 3000,
	max = 5,
})

fw.ents.registerItem("Medical Opiate Lab", {
	model = "models/props/cs_italy/it_mkt_table1.mdl",
	entity = "fw_opioid_crafting",
	price = 10000,
	max = 5,
})

fw.ents.registerItem("Opiate Refinery", {
	model = "models/props_wasteland/laundry_washer001a.mdl",
	entity = "fw_opioid_refinery",
	price = 1500,
	max = 10,
})


---
--- BEGIN WEAPON REGISTRATION
---


fw.ents.registerWeapon("Five-Seven", {
	model = "models/weapons/w_pist_fiveseven.mdl",
	weapon = "fw_gun_deagle",
	price = 100,
	both = true, -- creates both a shipment anda single
	-- shipment = true,
	-- single = true, -- both is equivalent to defining both these fields
})

fw.ents.registerWeapon("Desert Eagle", {
	model = "models/weapons/w_pist_deagle.mdl",
	weapon = "fw_gun_deagle",
	price = 200,
	both = true,
})

fw.ents.registerWeapon("Glock", {
	model = "models/weapons/w_pist_glock18.mdl",
	weapon = "fw_gun_glock",
	price = 200,
	both = true,
})

fw.ents.registerWeapon("P228", {
	model = "models/weapons/w_pist_p228.mdl",
	price = 100,
	weapon = "fw_gun_glock",
	both = true
})

fw.ents.registerWeapon("USP", {
	weapon = "fw_gun_usp",
	price = 230,
	model = "models/weapons/w_pist_usp.mdl",
	both = true,
})

fw.ents.registerWeapon("Dualies", {
	weapon = "fw_gun_dualies",
	price = 300,
	model = "models/weapons/w_pist_elite",
	both = true,
})


fw.ents.registerWeapon("MAC 10", {
	weapon = "fw_gun_mac10",
	price = 500,
	model = "models/weapons/w_smg_mac10.mdl",
	both = true,
})

fw.ents.registerWeapon("AK-47", {
	weapon = "fw_gun_ak47",
	price = 800,
	model = "models/weapons/w_rif_ak47.mdl",
	both = true,
})

fw.ents.registerWeapon("M3 Supor 90", {
	weapon = "fw_gun_m3",
	price = 600,
	model = "models/weapons/w_shot_m3super90.mdl",
	both = true,
})

fw.ents.registerWeapon("TMP", {
	weapon = "fw_gun_tmp",
	price = 520,
	model = "models/weapons/w_shot_m3super90.mdl",
	both = true,
})

fw.ents.registerWeapon("UMP", {
	weapon = "fw_gun_ump",
	price = 600,
	model = "models/weapons/w_smg_ump.mdl",
	both = true,
})

fw.ents.registerWeapon("Scout", {
	weapon = "fw_gun_scout",
	price = 600,
	model = "models/weapons/w_snip_scout.mdl",
	both = true,
})

fw.ents.registerWeapon("AWP", {
	price = 2000,
	weapon = "fw_gun_awp",
	model = "models/weapons/w_snip_awp.mdl",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("P90", {
	weapon = "fw_gun_p90",
	price = 1000,
	model = "models/weapons/w_smg_p90.mdl",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("SG552", {
	price = 3600,
	model = "models/weapons/w_rif_sg552.mdl",
	weapon = "fw_gun_sg552",
	both = true,
	team = TEAM_GUN
})

fw.ents.registerWeapon("AUG", {
	price = 4200,
	model = "models/weapons/w_rif_aug.mdl",
	weapon = "fw_gun_aug",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("G3SG1", {
	price = 5000,
	model = "models/weapons/w_snip_g3sg1.mdl",
	weapon = "fw_gun_g3sg1",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("MP5", {
	price = 500,
	model = "models/weapons/w_smg_mp5.mdl",
	weapon = "fw_gun_mp5",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("Famas", {
	price = 750,
	model = "models/weapons/w_rif_famas.mdl",
	weapon = "fw_gun_famas",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("Galil", {
	price = 960,
	model = "models/weapons/w_rif_galil.mdl",
	weapon = "fw_gun_galil",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("Galil", {
	price = 960,
	model = "models/weapons/w_rif_galil.mdl",
	weapon = "fw_gun_galil",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("M4A1", {
	price = 600,
	model = "models/weapons/w_rif_m4a1.mdl",
	weapon = "fw_gun_m4a1",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("XM-1014", {
	price = 600,
	model = "models/weapons/w_shot_xm1014.mdl",
	weapon = "fw_gun_m4a1",
	both = true,
	team = TEAM_GUN,
})

fw.ents.registerWeapon("Repair Tool", {
	weapon = "fw_repairtool",
	price = 300,
	model = "",
	single = true,
})

fw.ents.registerWeapon("Cutting Torch", {
	model = "models/weapons/w_IRifle.mdl",
	weapon = "fw_cuttingtorch",
	price = 800,
	both = true,
})
