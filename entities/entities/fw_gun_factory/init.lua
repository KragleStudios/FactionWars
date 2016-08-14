util.AddNetworkString("Fac_ProduceGun")

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

	self.Consumes = {
		power = 1,
	}

	fw.resource.addEntity(self)
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_gun_scrap" and not ent.Used then
		ent.Used = true
		ent:Remove()
		self:FWSetResource("scrap", self:FWHaveResource("scrap") + 1)
	end
end

function ENT:SpawnGun(type)
	timer.Simple(5, function()
		local ent = ents.Create("fw_gun")
		local weapon = outputs[type][math.random(1, #outputs[type])]
		ent:SetWeapon(weapon)
		ent:SetBuff(table.Random(table.GetKeys(fw.weapons.buffs)))
		ent:SetModel(weapons.Get(weapon).WorldModel)
		ent:SetPos(self:GetPos())
		ent:Spawn()
	end)

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	effect:SetNormal(self:GetPos():Up())
	util.Effect("ManhackSparks", effect)
end

function ENT:OnResourceUpdate()
	local res = self:FWHaveResource("parts")
	if res < self.MaxConsumption.parts then
		self:ConsumeResource("parts", self.MaxConsumption.parts)
	end
end

function ENT:OnRemove()
	fw.resource.removeEntity(self)
end

net.Receive("Fac_ProduceGun", function(len, ply)
	local ent = net.ReadEntity()
	local type = net.ReadUInt(4)

	if ply:GetPos():Distance(ent:GetPos()) > 200 or not ply:Alive() then return end

	local parts = ent:FWHaveResource("parts")
	local scrap = ent:FWHaveResource("scrap")

	if type == 0 then
		if parts >= 1 and scrap >= 1 then
			ent:SpawnGun("pistol")
		else
			ply:FWChatPrint("The factory requires 1 part and 1 scrap to produce this gun.")
		end
	elseif type == 1 then
		if parts >= 2 and scrap >= 2 then
			ent:SpawnGun("smg")
		else
			ply:FWChatPrint("The factory requires 2 parts and 2 scrap to produce this gun.")
		end
	elseif type == 2 then
		if parts >= 3 and scrap >= 2 then
			ent:SpawnGun("twohanded")
		else
			ply:FWChatPrint("The factory requires 3 parts and 2 scrap to produce this gun.")
		end
	elseif type == 3 then
		if parts >= 1 and scrap >= 1 then
			ent:SpawnGun("rifle")
		else
			ply:FWChatPrint("The factory requires 3 parts and 3 scrap to produce this gun.")
		end
	end
end)
