fw.ents.registerItem("Tier 1 Money Printer", {
	stringID = "t1printer",
	color =  Color(211, 84, 0),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier1",
	price = 1500,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Tier 2 Money Printer", {
	stringID = "t2printer",
	color =  Color(243, 156, 18),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier2",
	price = 3000,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Tier 3 Money Printer", {
	stringID = "t3printer",
	color =  Color(52, 73, 94),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier3",
	price = 5000,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Tier 4 Money Printer", {
	stringID = "t4printer",
	color =  Color(142, 68, 173),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier4",
	price = 12500,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Tier 5 Money Printer", {
	stringID = "t5printer",
	color =  Color(192, 57, 43),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier5",
	price = 25000,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Titan Money Printer", {
	stringID = "titan",
	color =  Color(44, 62, 80),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_titan",
	price = 40000,
	category = "Printers",
	storable = false,
})

fw.ents.registerItem("Printer Paper", {
	stringID = "printer_paper",
	color =  Color(44, 62, 80),
	model = "models/props_junk/cardboard_box003a.mdl",
	entity = "fw_paper",
	price = 50,
	category = "Printers",
	storable = false,
})

---
--- BEGIN OTHER WEAPON REGISTRATION
---
fw.ents.registerItem("Turret", {
	stringID = "turret",
	color =  Color(44, 62, 80),
	model = "models/combine_turrets/ground_turret.mdl",
	entity = "fw_turret",
	price = 40000,
	category = "Automated Weapons",
	storable = false,
	factions = {FACTION_GANGA, FACTION_GANGB}
})

fw.ents.registerItem("Radar", {
	stringID = "radar",
	color =  Color(44, 62, 80),
	model = "",
	entity = "fw_radar",
	price = 1,
	category = "Automated Weapons",
	storable = false,
	factions = {FACTION_GANGA, FACTION_GANGB}
})

---
--- BEGIN RESOURCE REGISTRATION
---

fw.ents.registerItem("Generator", {
	stringID = "generator",
	color =  Color(44, 62, 80),
	model = "models/props_vehicles/generatortrailer01.mdl",
	entity = "fw_generator",
	price = 2000,
	category = "Resources",
	storable = false,
})

fw.ents.registerItem("Health Machine", {
	stringID = "h_machine",
	color =  Color(44, 62, 80),
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_healthmachine",
	price = 40000,
	category = "Entities",
	storable = false,
})

fw.ents.registerItem("Armour Machine", {
	stringID = "a_machine",
	color =  Color(44, 62, 80),
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_armourmachine",
	price = 40000,
	category = "Entities",
	storable = false,
})

fw.ents.registerItem("Respawn Point", {
	stringID = "spawnpoint",
	color =  Color(44, 62, 80),
	model = "",
	entity = "fw_respawn_point",
	price = 1,
	category = "Entities",
	storable = false,
})

---
--- BEGIN WEAPON REGISTRATION
---
local function regWep(name, sID, col, mdl, ent, price, rmv, cat, ship, stor, job, faction)
	fw.ents.registerWeapon(name, {
			stringID = sID,
			color = col,
			model = mdl,
			entity = ent,
			price = price,
			removeOnDisc = rmv,
			category = cat,
			shipment = ship,
			storable = stor,
			jobs = job,
			factions = faction
		})
end

regWep("Five-Seven", "fiveseven", Color(0,0,0), "models/weapons/w_pist_fiveseven.mdl", "fw_gun_fiveseven", 100, false, "Weapons", false, true)
regWep("Desert Eagle", "deagle", Color(0,0,0), "models/weapons/w_pist_deagle.mdl", "fw_gun_deagle", 200, false, "Weapons", false, true)
regWep("Glock", "glock", Color(0,0,0), "models/weapons/w_pist_glock18.mdl", "fw_gun_glock", 100, false, "Weapons", false, true)
regWep("P228", "p228", Color(0,0,0), "models/weapons/w_pist_p228.mdl", "fw_gun_p228", 100, false, "Weapons", false, true)
regWep("USP", "usp", Color(0,0,0), "models/weapons/w_pist_usp.mdl", "fw_gun_usp", 100, false, "Weapons", false, true)
regWep("AK-47", "ak47", Color(0,0,0), "models/weapons/w_rif_ak47.mdl", "fw_gun_ak47", 200, false, "Weapons", false, true)
regWep("Dualies", "dualies", Color(0,0,0), "models/weapons/w_pist_elite", "fw_gun_dualies", 250, false, "Weapons", false, true)
regWep("Mac 10", "mac10", Color(0,0,0), "models/weapons/w_smg_mac10.mdl", "fw_gun_mac10", 200, false, "Weapons", false, true)

regWep("AWP", "awp", Color(0,0,0), "models/weapons/w_snip_awp.mdl", "fw_gun_awp", 400, false, "Weapons", false, true, {TEAM_GUN})
regWep("M3 Super 90", "m3", Color(0,0,0), "models/weapons/w_shot_m3super90.mdl", "fw_gun_m3", 400, false, "Weapons", false, true, {TEAM_GUN})
regWep("P90", "p90", Color(0,0,0), "models/weapons/w_smg_p90.mdl", "fw_gun_p90", 200, false, "Weapons", false, true, {TEAM_GUN})
regWep("AUG", "aug", Color(0,0,0), "models/weapons/w_rif_aug.mdl", "fw_gun_aug", 300, false, "Weapons", false, true, {TEAM_GUN})
regWep("Famas", "famas", Color(0,0,0), "models/weapons/w_rif_famas.mdl", "fw_gun_famas", 300, false, "Weapons", false, true, {TEAM_GUN})
regWep("Galil", "galil", Color(0,0,0), "models/weapons/w_rif_galil.mdl", "fw_gun_galil", 300, false, "Weapons", false, true, {TEAM_GUN})
regWep("M4A1", "m4a1", Color(0,0,0), "models/weapons/w_rif_m4a1.mdl", "fw_gun_m4a1", 350, false, "Weapons", false, true, {TEAM_GUN})
regWep("SG552", "sg552", Color(0,0,0), "models/weapons/w_rif_sg552.mdl", "fw_gun_sg552", 300, false, "Weapons", false, true, {TEAM_GUN})
regWep("XM-1014", "xm1014", Color(0,0,0), "models/weapons/w_shot_xm1014.mdl", "fw_gun_xm1014", 200, false, "Weapons", false, true, {TEAM_GUN})
regWep("MP5", "mp5", Color(0,0,0), "models/weapons/w_smg_mp5.mdl", "fw_gun_mp5", 300, false, "Weapons", false, true, {TEAM_GUN})
regWep("TMP", "tmp", Color(0,0,0), "models/weapons/w_smg_tmp.mdl", "fw_gun_tmp", 200, false, "Weapons", false, true, {TEAM_GUN})
regWep("UMP", "ump", Color(0,0,0), "models/weapons/w_smg_ump.mdl", "fw_gun_ump", 200, false, "Weapons", false, true, {TEAM_GUN})
regWep("Scout", "scout", Color(0,0,0), "models/weapons/w_snip_scout.mdl", "fw_gun_scout", 500, false, "Weapons", false, true, {TEAM_GUN})
regWep("G3SG1", "g3sg1", Color(0,0,0), "models/weapons/w_snip_g3sg1.mdl", "fw_gun_g3sg1", 500, false, "Weapons", false, true, {TEAM_GUN})

regWep("Repair Tool", "rtool", Color(0,0,0), "", "fw_repairtool", 1000, false, "Tools", false, true, {TEAM_BMD})


--TODO: Shipments
fw.ents.registerShipment("Blowtorch", {
	stringID = "blowtorch",
	color = Color(0, 0, 0),
	model = "",
	entity = "fw_cuttingtorch",
	price = 1,
	storable = true,
	weapon = true,

	shipmentCount = 10,
	seperate = true,
	seperatePrice = 100
})
