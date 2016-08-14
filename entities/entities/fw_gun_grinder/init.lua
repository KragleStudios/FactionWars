AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

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

local amounts = {
	pistol = 1,
	smg = 2,
	twohanded = 3,
	rifle = 3,
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

	self.Storage = {
		parts = 0,
	}

	fw.resource.addEntity(self)
end

function ENT:ProcessGun(ent)
	for k,v in pairs(outputs) do
		for t,g in pairs(v) do
			if g == ent:GetWeapon() then
				local amount = amounts[k]
				ent:Remove()
				local curParts = self.Storage.parts
				self.Storage = {
					parts = math.Clamp(curParts + amount, 0, self.MaxStorage.parts)
				}
			end
		end
	end
end

function ENT:OnResourceUpdate()
	local res = self:FWHaveResource("power")
	if res < self.MaxConsumption.power then
		self:ConsumeResource("power", self.MaxConsumption.power)
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_gun" and not ent.Used and self:FWHaveResource("power") >= self.MaxConsumption.power then
		ent.Used = true
		self:ProcessGun(ent)
	end
end

function ENT:OnRemove()
	fw.resource.removeEntity(self)
end