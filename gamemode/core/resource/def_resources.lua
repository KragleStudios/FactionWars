if SERVER then
	resource.AddSingleFile('materials/kragle/resources/x64-electric.png')
	resource.AddSingleFile('materials/kragle/resources/x64-oil.png')
	resource.AddSingleFile('materials/kragle/resources/x64-watertap.png')
	resource.AddSingleFile('materials/kragle/resources/x64-paper.png')
end

fw.resource.register('power', {
	PrintName = 'Power',
	material = CLIENT and Material('kragle/resources/x64-electric.png')
})

fw.resource.register('gas', {
	PrintName = 'Gas',
	material = CLIENT and Material('kragle/resources/x64-oil.png')
})

fw.resource.register('water', {
	PrintName = 'Water',
	material = CLIENT and Material('kragle/resources/x64-watertap.png')
})

fw.resource.register('paper', {
	PrintName = 'Paper',
	material = CLIENT and Material('kragle/resources/x64-paper.png')
})

fw.resource.register('scrap', {
	PrintName = 'Scrap',
	material = CLIENT and Material('kragle/resources/x64-paper.png')
})

fw.resource.register('parts', {
	PrintName = 'Parts',
	material = CLIENT and Material('kragle/resources/x64-paper.png')
})
