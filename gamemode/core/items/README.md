# Entity & Item Registration

# Available Commands & Parameters
# fw.ents.registerItem(Item Name, {
		model = "", -- world model for item(REQUIRED)
		stringID = "", -- unique id to index this item by (REQUIRED)
		entity = "", -- entity classname (REQUIRED)
		price = int, -- the price for this entity (REQUIRED)

		max = int, -- (OPTIONAL default = 0[infinite])
		color = Color(r, g, b), -- (OPTIONAL default = Color(100, 100, 100))
		category = "", (OPTIONAL default = "General Merch") 
		storable = bool, (OPTIONAL default = false, store in the inventory?)
	})

# fw.ents.registerWeapon(Weapon Name, {
		--PARAMETERS EXACT SAME AS ABOVE
	})

# fw.ents.registerShipment({
		model = "", -- world model for item(REQUIRED)
		stringID = "", -- unique id to index this item by (REQUIRED)
		entity = "", -- entity classname (REQUIRED)
		price = int, -- the price for this entity (REQUIRED)
		shipmentCount = int, -- how many items are in this shipment (REQUIRED)

		max = int, -- (OPTIONAL default = 0[infinite])
		color = Color(r, g, b), -- (OPTIONAL default = Color(100, 100, 100))
		category = "", (OPTIONAL default = "General Merch") 
		
		seperate = bool, --should we make a seperate item to sell this item in not a shipment?
		seperatePrice = int, (REQUIRED if seperate, how much each item should be paid for)
		weapon = bool, (OPTIONAL default = false, is this item going to be a weapon?)
		useable = boo, (OPTIONAL default = false, is tis item able to be used?)

	})