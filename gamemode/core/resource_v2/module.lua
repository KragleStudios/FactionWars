if SERVER then
	AddCSLuaFile()
end

require 'ra'

fw.resource = {}

local resource_entities = {}

fw.resource.types = {}
fw.resource.typeById = {}
function fw.resource.register(type, meta)
	meta.type = type
	meta.id = table.insert(fw.resource.typeById, meta)
	fw.resource.types[type] = meta
	return meta.id
end

function fw.resource.resourceEntity(ent)
	ent.fwResources = {}
	table.insert(resource_entities, ent)
end

function fw.resource.removeEntity(ent)
	table.RemoveByValue(resource_entities, ent)
end

ra.include_sv 'resource_sv.lua'
ra.include_cl 'resource_cl.lua'
