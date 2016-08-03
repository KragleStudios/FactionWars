AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("cl_init.lua")

local outputs = {
	pistol = {
		"fw_gun_fiveseven",
		"fw_gun_deagle",
		"fw_gun_dualies",
		"fw_gun_glock",
		"fw_gun_p228",
		"fw_gun_usp",
	},
	smg = {
		"fw_gun_p90",
		"fw_gun_mac10",
		"fw_gun_mp5",
		"fw_gun_tmp",
		"fw_gun_ump",
	},
	twohanded = {
		"fw_gun_m3",
		"fw_gun_ak47",
		"fw_gun_aug",
		"fw_gun_famas",
		"fw_gun_galil",
		"fw_gun_m4a1",
		"fw_gun_sg552",
		"fw_gun_xm1014"
	},
	rifle = {
		"fw_gun_awp",
		"fw_gun_scout",
		"fw_gun_g3sg1"
	}
}

ENT.Parts = 0
ENT.Scrap = 0

function ENT:Initialize()
	self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_gun_parts" then
		self.Parts = self.Parts + 1
		ent:Remove()
	elseif ent:GetClass() == "fw_gun_scrap" then
		self.Scrap = self.Scrap + 1
		ent:Remove()
	end
end

function ENT:SpawnGun(type)
	local ent = ents.Create("fw_gun")
	local weapon = outputs[type][math.random(1, #outputs[type])]
	ent:SetWeapon(weapon)
	ent:SetBuff(table.Random(fw.weapons.buffs))
	ent:SetModel(weapons.Get(weapon).WorldModel)
	ent:Spawn()
end

function ENT:Use(ply, trigger)
	if self.Parts >= 3 and self.Scrap >= 3 then
		self:SpawnGun("rifle")
	elseif self.Parts >= 3 and self.Scrap >= 2 then
		self:SpawnGun("twohanded")
	elseif self.Parts >= 2 and self.Scrap >= 2 then
		self:SpawnGun("smg")
	elseif self.Parts >= 1 and self.Scrap >= 1 then
		self:SpawnGun("pistol")
	end
end