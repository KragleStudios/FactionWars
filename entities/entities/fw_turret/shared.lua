ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Name = "Turret"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "UpgradeStatus")
	self:NetworkVar("Entity", 1, "Owner")
	self:NetworkVar("String", 2, "Remaining")
	self:NetworkVar("Bool", 3, "Targeting")
	self:NetworkVar("Bool", 4, "Status") --true for on, off for off
end
