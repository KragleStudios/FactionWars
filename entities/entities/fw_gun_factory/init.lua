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

function ENT:Initialize()
	self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()

	self:SetTrigger(true)

	self:SetParts(0)
	self:SetScrap(0)
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_gun_parts" and not ent.Used then
		ent.Used = true
		ent:Remove()
		self:SetParts(self:GetParts() + 1)
	elseif ent:GetClass() == "fw_gun_scrap" and not ent.Used then
		ent.Used = true
		ent:Remove()
		self:SetScrap(self:GetScrap() + 1)
	end
end

function ENT:SpawnGun(type)
	local ent = ents.Create("fw_gun")
	local weapon = outputs[type][math.random(1, #outputs[type])]
	ent:SetWeapon(weapon)
	ent:SetBuff(table.Random(table.GetKeys(fw.weapons.buffs)))
	ent:SetModel(weapons.Get(weapon).WorldModel)
	ent:SetPos(self:GetPos())
	ent:Spawn()
end

function ENT:Use(ply, trigger)
	local scrap = self:GetScrap()
	local parts = self:GetParts()

	if parts >= 3 and scrap >= 3 then
		self:SpawnGun("rifle")
		self:SetParts(self:GetParts() - 3)
		self:SetScrap(self:GetScrap() - 3)
	elseif parts >= 3 and scrap >= 2 then
		self:SpawnGun("twohanded")
		self:SetParts(self:GetParts() - 3)
		self:SetScrap(self:GetScrap() - 2)
	elseif parts >= 2 and scrap >= 2 then
		self:SpawnGun("smg")
		self:SetParts(self:GetParts() - 2)
		self:SetScrap(self:GetScrap() - 2)
	elseif parts >= 1 and scrap >= 1 then
		self:SpawnGun("pistol")
		self:SetParts(self:GetParts() - 1)
		self:SetScrap(self:GetScrap() - 1)
	end
end
