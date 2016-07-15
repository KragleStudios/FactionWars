fw.printers.printers = {}

function fw.printers.createPrinter(name, config, entity)
	assert(entity, "printer entity name not provided")
	assert(config.PrintSpeed, "no print speed provided")
	assert(config.PowerRequired, "no power requirement provided")
	assert(config.PrintAmount, "no print amount provided")
	assert(config.PaperCap, "no paper cap provided")
	assert(config.PaperDrain, "no paper drain provided")
	-- Color is an optional property

	config.Name = name
	fw.printers.printers[entity] = config
end

fw.hook.Add("Initialize", "LoadPrinters", function()
	for e,p in pairs(fw.printers.printers) do
		local printer = scripted_ents.Get("fw_printer_base")
		for k,v in pairs(p) do
			printer[k] = v
		end

		scripted_ents.Register(printer, e)
	end
end)