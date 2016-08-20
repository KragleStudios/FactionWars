local Entity = FindMetaTable('Entity')

function Entity:FWSetupHealth()
	assert(self.MaxHealth, 'Entity:FWSetupHealth requires that the MaxHealth property for the entity is defined')

	-- TODO: thelastpenguin finish writing health code
end

function Entity:FWRenderHealth()
	-- draws health circle if being looked at
end
