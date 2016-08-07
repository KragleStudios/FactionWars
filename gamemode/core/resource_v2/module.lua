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

if SERVER then
	function Entity:FWHaveResource(name)
		return ent.fwResources[name] or ent.fwResourcesStatic[name] or 0
	end

	function Entity:FWStoringResource(name)
		return ent.Storage and ent.Storage[name] or 0
	end

	function Entity:FWProducingResource(name)
		return ent.Produces and ent.Produces[name] or 0
	end
else
	function Entity:FWHaveResource(name) -- how much of the resource it has
		local info = self:FWGetResourceInfo()
		return info and info.haveResources and info.haveResources[name] or 0
	end

	function Entity:FWStoringResource(name) -- how much of the resource is stored
		local info = self:FWGetResourceInfo()
		return info and info.amStoring and info.amStoring[name] or 0
	end

	function Entity:FWProducingResource(name) -- how much of the resource is being produced
		local info = self:FWGetResourceInfo()
		return info and info.amProducing and info.amProducing[name] or 0
	end
end

function Entity:FWHasAllResources(table)
	for resource, amount in pairs(table) do
		if self:FWHaveResource(resource) < amount then
			return false
		end
	end
	return true
end

-- code too big to reasonably put here
ra.include_sv 'resource_sv.lua'
ra.include_cl 'display_cl.lua'
ra.include_sh 'def_resources.lua'
