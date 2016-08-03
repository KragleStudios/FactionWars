ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Name = "Respawn Point"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Faction Wars"

ENT.Healt = 200

--setup our data
function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("Int", 1, "Healt")
end
