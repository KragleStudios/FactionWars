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

function ENT:SpawnGun(type)
	timer.Simple(1, function()
		local ent = ents.Create("fw_gun")
		local weapon = outputs[type][math.random(1, #outputs[type])]
		ent:SetWeapon(weapon)
		ent:SetBuff(table.Random(table.GetKeys(fw.weapons.buffs)))
		ent:SetModel(weapons.Get(weapon).WorldModel)
		ent:SetPos(self:GetPos() + Vector(0, 0, 30))
		ent:Spawn()
	end)

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	effect:SetNormal(self:GetPos():Up())
	util.Effect("ManhackSparks", effect)
end

function ENT:OnRemove()
	fw.resource.removeEntity(self)
end

net.Receive("Fac_ProduceGun", function(len, ply)
	local ent = net.ReadEntity()
	local type = net.ReadUInt(4)

	if ply:GetPos():Distance(ent:GetPos()) > 200 or not ply:Alive() then return end

	local parts = ent:FWHaveResource("parts")

	if type == 0 then
		if parts >= 1 then
			ent:ConsumeResource("parts", 1)
			ent:SpawnGun("pistol")
		else
			ply:FWChatPrint("The factory requires 1 part to produce this gun.")
		end
	elseif type == 1 then
		if parts >= 2 then
			ent:ConsumeResource("parts", 2)
			ent:SpawnGun("smg")
		else
			ply:FWChatPrint("The factory requires 2 parts to produce this gun.")
		end
	elseif type == 2 then
		if parts >= 3 then
			ent:ConsumeResource("parts", 3)
			ent:SpawnGun("twohanded")
		else
			ply:FWChatPrint("The factory requires 3 parts to produce this gun.")
		end
	elseif type == 3 then
		if parts >= 1 then
			ent:ConsumeResource("parts", 1)
			ent:SpawnGun("rifle")
		else
			ply:FWChatPrint("The factory requires 3 parts to produce this gun.")
		end
	end
end)
