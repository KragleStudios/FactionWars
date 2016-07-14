fw.printers.createPrinter("Tier 1 Money Printer", {
	PrintSpeed = 300,
	PrintAmount = 500,
	PowerRequired = 100,
	PaperCap = 65,
	PaperDrain = 5,
	Color = Color(211, 84, 0, 100)
}, "fw_printer_tier1") -- 500 * (15/5) = $1500

fw.printers.createPrinter("Tier 2 Money Printer", {
	PrintSpeed = 240,
	PrintAmount = 750,
	PowerRequired = 125,
	PaperCap = 75,
	PaperDrain = 5,
	Color = Color(243, 156, 18)
}, "fw_printer_tier2") -- 750 * (15/4) = $2812 (cost: $2750)

fw.printers.createPrinter("Tier 3 Money Printer", {
	PrintSpeed = 180,
	PrintAmount = 1000,
	PowerRequired = 150,
	PaperCap = 90,
	PaperDrain = 4,
	Color = Color(52, 73, 94)
}, "fw_printer_tier3") -- 1000 * (15/3) = $5000

fw.printers.createPrinter("Tier 4 Money Printer", {
	PrintSpeed = 120,
	PrintAmount = 1500,
	PowerRequired = 200,
	PaperCap = 115,
	PaperDrain = 4,
	Color = Color(142, 68, 173)
}, "fw_printer_tier4") -- 1500 * (15/2) = $11250 (cost: $12500)

fw.printers.createPrinter("Tier 5 Money Printer", {
	PrintSpeed = 90,
	PrintAmount = 2000,
	PowerRequired = 200,
	PaperCap = 175,
	PaperDrain = 3,
	Color = Color(192, 57, 43)
}, "fw_printer_tier5") -- 2000 * (15/1.5) = $20000 (cost: $25000, extra cost is for the paper usage)

fw.printers.createPrinter("Titan", {
	PrintSpeed = 60,
	PrintAmount = 2250,
	PowerRequired = 275,
	PaperCap = 350,
	PaperDrain = 2,
	Color = Color(44, 62, 80)
}, "fw_printer_titan") -- 2250 * 15 = $33750 (cost: $40000, extra cost is for paper storage/usage)
