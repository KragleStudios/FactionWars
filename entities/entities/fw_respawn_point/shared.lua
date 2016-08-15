ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Respawn Point"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Faction Wars"

ENT.Healt = 200
ENT.Resources = true

--setup our data
function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("Int", 1, "Healt")
end
