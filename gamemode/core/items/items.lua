fw.ents.registerItem("Tier 1 Money Printer", {
	stringID = "t1printer",
	color =  Color(211, 84, 0),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier1",
	max = 0,
	price = 1500,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Tier 2 Money Printer", {
	stringID = "t2printer",
	color =  Color(243, 156, 18),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier2",
	max = 0,
	price = 2750,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Tier 3 Money Printer", {
	stringID = "t3printer",
	color =  Color(52, 73, 94),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier3",
	max = 0,
	price = 5000,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Tier 4 Money Printer", {
	stringID = "t4printer",
	color =  Color(142, 68, 173),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier4",
	max = 0,
	price = 12500,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Tier 5 Money Printer", {
	stringID = "t5printer",
	color =  Color(192, 57, 43),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_tier5",
	max = 0,
	price = 25000,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Titan Money Printer", {
	stringID = "titan",
	color =  Color(44, 62, 80),
	model = "models/props_c17/consolebox01a.mdl",
	entity = "fw_printer_titan",
	max = 0,
	price = 40000,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Printer Paper", {
	stringID = "printer_paper",
	color =  Color(44, 62, 80),
	model = "models/props_junk/cardboard_box003a.mdl",
	entity = "fw_printer_paper",
	max = 0,
	price = 50,
	removeOnDisc = true,
	category = "Printers",
	shipment = false,
	storable = false,
})

---
--- BEGIN OTHER WEAPON REGISTRATION
---
fw.ents.registerItem("Turret", {
	stringID = "titan",
	color =  Color(44, 62, 80),
	model = "models/combine_turrets/ground_turret.mdl",
	entity = "fw_turret",
	max = 0,
	price = 40000,
	removeOnDisc = false,
	category = "Automated Weapons",
	shipment = false,
	storable = false,
	factions = {FACTION_GANGA, FACTION_GANGB}
})

fw.ents.registerItem("Small Bomb", {
	stringID = "smallbomb",
	color =  Color(44, 62, 80),
	model = "models/props_c17/oildrum001_explosive.mdl",
	entity = "fw_smallbomb",
	max = 0,
	price = 2000,
	removeOnDisc = false,
	category = "Automated Weapons",
	shipment = false,
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
	max = 0,
	price = 2000,
	removeOnDisc = false,
	category = "Resources",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Health Machine", {
	stringID = "h_machine",
	color =  Color(44, 62, 80),
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_healthmachine",
	max = 0,
	price = 40000,
	removeOnDisc = false,
	category = "Entities",
	shipment = false,
	storable = false,
})

fw.ents.registerItem("Armour Machine", {
	stringID = "a_machine",
	color =  Color(44, 62, 80),
	model = "models/props_lab/reciever_cart.mdl",
	entity = "fw_armourmachine",
	max = 0,
	price = 40000,
	removeOnDisc = false,
	category = "Entities",
	shipment = false,
	storable = false,
})

---
--- BEGIN WEAPON REGISTRATION
---

local function regWep(name, sID, col, mdl, ent, max, price, rmv, cat, ship, wep, stor, job, faction)
	fw.ents.registerItem(name, {
			stringID = sID,
			color = col,
			model = mdl,
			max = max, 
			entity = ent,
			price = price,
			removeOnDisc = rmv,
			category = cat,
			shipment = ship,
			storable = stor,
			weapon = wep,
			jobs = job,
			factions = faction
		})
end

regWep("Five-Seven", "fiveseven", Color(0,0,0), "models/weapons/w_pist_fiveseven.mdl", "fw_gun_fiveseven", 0, 100, false, "Weapons", false, true, true)
regWep("Desert Eagle", "deagle", Color(0,0,0), "models/weapons/w_pist_deagle.mdl", "fw_gun_deagle", 0, 200, false, "Weapons", false, true, true)
regWep("Glock", "glock", Color(0,0,0), "models/weapons/w_pist_glock18.mdl", "fw_gun_glock", 0, 100, false, "Weapons", false, true, true)
regWep("P228", "p228", Color(0,0,0), "models/weapons/w_pist_p228.mdl", "fw_gun_p228", 0, 100, false, "Weapons", false, true, true)
regWep("USP", "usp", Color(0,0,0), "models/weapons/w_pist_usp.mdl", "fw_gun_usp", 0, 100, false, "Weapons", false, true, true)
regWep("AK-47", "ak47", Color(0,0,0), "models/weapons/w_rif_ak47.mdl", "fw_gun_ak47", 0, 200, false, "Weapons", false, true, true)
regWep("Dualies", "dualies", Color(0,0,0), "models/weapons/w_pist_elite", "fw_gun_dualies", 0, 250, false, "Weapons", false, true, true)
regWep("Mac 10", "mac10", Color(0,0,0), "models/weapons/w_smg_mac10.mdl", "fw_gun_mac10", 0, 200, false, "Weapons", false, true, true)

regWep("AWP", "awp", Color(0,0,0), "models/weapons/w_snip_awp.mdl", "fw_gun_awp", 0, 400, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("M3 Super 90", "m3", Color(0,0,0), "models/weapons/w_shot_m3super90.mdl", "fw_gun_m3", 0, 400, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("P90", "p90", Color(0,0,0), "models/weapons/w_smg_p90.mdl", "fw_gun_p90", 0, 200, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("AUG", "aug", Color(0,0,0), "models/weapons/w_rif_aug.mdl", "fw_gun_aug", 0, 300, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("Famas", "famas", Color(0,0,0), "models/weapons/w_rif_famas.mdl", "fw_gun_famas", 0, 300, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("Galil", "galil", Color(0,0,0), "models/weapons/w_rif_galil.mdl", "fw_gun_galil", 0, 300, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("M4A1", "m4a1", Color(0,0,0), "models/weapons/w_rif_m4a1.mdl", "fw_gun_m4a1", 0, 350, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("SG552", "sg552", Color(0,0,0), "models/weapons/w_rif_sg552.mdl", "fw_gun_sg552", 0, 300, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("XM-1014", "xm1014", Color(0,0,0), "models/weapons/w_shot_xm1014.mdl", "fw_gun_xm1014", 0, 200, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("MP5", "mp5", Color(0,0,0), "models/weapons/w_smg_mp5.mdl", "fw_gun_mp5", 0, 300, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("TMP", "tmp", Color(0,0,0), "models/weapons/w_smg_tmp.mdl", "fw_gun_tmp", 0, 200, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("UMP", "ump", Color(0,0,0), "models/weapons/w_smg_ump.mdl", "fw_gun_ump", 0, 200, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("Scout", "scout", Color(0,0,0), "models/weapons/w_snip_scout.mdl", "fw_gun_scout", 0, 500, false, "Weapons", false, true, true, {TEAM_GUN})
regWep("G3SG1", "g3sg1", Color(0,0,0), "models/weapons/w_snip_g3sg1.mdl", "fw_gun_g3sg1", 0, 500, false, "Weapons", false, true, true, {TEAM_GUN})

regWep("Blowtorch", "blowtorch", Color(0,0,0), "models/weapons/w_IRifle.mdl", "fw_cttingtorch", 0, 1000, false, "Tools", false, true, true, {TEAM_BMD})
regWep("Repair Tool", "rtool", Color(0,0,0), "", "fw_repairtool", 0, 1000, false, "Tools", false, true, true, {TEAM_BMD})


--TODO: Shipments
fw.ents.registerItem("Blowtorch Shipment", {
	stringID = "blowtorchship",
	color = Color(0, 0, 0),
	model = "", --this is the model shown on the menu display, and doesn't have to mach the ent model
	entity = "fw_cuttingtorch", --this MUST be the entity classname 
	max = 0,
	price = 100,
	storable = true,
	weapon = true,
	useable = false,
	shipment = true,
	shipmentCount = 10,
	--optional
	--removeOnDisc = true/false, remove this when the player leaves
	--category = "General Merch, custom cat",
	--faction = true/false for all factions, or {FACTION_*} for factions,
	--jobs = {table of teams, TEAM_*}
	--onSpawn = function(item, ply) end,
	--canBuy = function(item, ply) return true/false end
	--shipment = true/false,
	--shipmentCount = 10 -- how many come in a shipment?
})