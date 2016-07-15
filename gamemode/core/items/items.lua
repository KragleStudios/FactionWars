fw.ents.registerItem("Blowtorch", {
	stringID = "blowtorch",
	color = Color(0, 0, 0),
	model = "", --this is the model shown on the menu display, and doesn't have to mach the ent model
	entity = "ent_class", --this MUST be the entity classname 
	max = 0,
	price = 100,
	storable = false,
	--optional
	--removeOnDisc = true/false, remove this when the player leaves
	--category = "General Merch, custom cat",
	--factionOnly = true/false for all factions, or "FACTION_*" for one faction,
	--jobOnly = {table of teams, TEAM_*}
	--onSpawn = function(item, ply) end,
	--canBuy = function(item, ply) return true/false end
	--shipment = true/false,
	--shipmentCount = 10 -- how many come in a shipment?
})

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