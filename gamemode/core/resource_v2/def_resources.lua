if SERVER then
	resource.AddSingleFile('kragle/resources/x64-electric.png')
	resource.AddSingleFile('kragle/resources/x64-oil.png')
	resource.AddSingleFile('kragle/resources/x64-watertap.png')
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
