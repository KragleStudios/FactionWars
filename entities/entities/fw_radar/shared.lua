ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Radar"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Faction Wars"

--how big is the detection distance?
ENT.radius = 1000

--What whappens should we NOT show as "bad" on the radar
ENT.WepBlacklist = {
	["weapon_physgun"] = true,
	["weapon_gravgun"] = true,
	["gmod_hands"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true
}

--setup our data
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "UpgradeStatus")
	self:NetworkVar("Bool", 1, "Status")
end
