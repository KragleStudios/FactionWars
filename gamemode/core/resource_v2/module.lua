if SERVER then
	AddCSLuaFile()
end

-- require external libraries
require 'ra'

-- require internal libraries
fw.dep(SHARED, 'hook')
fw.dep(CLIENT, '3d2d')
fw.dep(CLIENT, 'ui')

-- core shared function definitions

fw.resource = fw.resource or {}

local resource_entities = fw.resource.resource_entities or {}
fw.resource.resource_entities = resource_entities

fw.resource.types = {}
fw.resource.typeById = {}
function fw.resource.register(type, meta)
	meta.type = type
	meta.id = table.insert(fw.resource.typeById, meta)
	fw.resource.types[type] = meta
	return meta.id
end

function fw.resource.getIdByStringName(stringName)
	return fw.resource.typeById[stringName].id
end


--
-- META METHODS
--
local Entity = FindMetaTable('Entity')
function Entity:FWGetResourceInfo()
	if not ndoc.table.fwEntityResources then return end
	return ndoc.table.fwEntityResources[self:EntIndex()]
end

-- code too big to reasonably put here
ra.include_sv 'resource_sv.lua'
ra.include_cl 'display_cl.lua'
ra.include_sh 'def_resources.lua'
