AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	self:PhysWake()

	self:SetTrigger(true)

	self:SetNextPrintTime(CurTime() + self.PrintSpeed)
	self:SetMoney(0)
	self:SetPaper(self.PaperCap)
	self:SetPrintStatus(false)

	self:SetColor(self.Color)

	self.Sound = CreateSound(self, "ambient/levels/labs/equipment_printer_loop1.wav")
	self.Sound:SetSoundLevel(57)

	self.Consumes = {
		["power"] = self.PowerRequired,
	}

	fw.resource.addEntity(self)

	self:SetHealth(self.MaxHealth)
end

function ENT:OnTakeDamage(dmginfo)
	if self:GetHealth() <= 0 then return end
	self:SetHealth(self:GetHealth() - dmginfo:GetDamage())
	if self:GetHealth() <= 0 then
		self:Ignite(30, 100)
		timer.Simple(5, function()
			util.BlastDamage(self, self, self:GetPos(), 100, 100)
			self:Remove()
		end)
	end
end

function ENT:OnResourceUpdate()
	local paper = self:FWHaveResource("paper")
	if paper < self.PaperDrain then
		self:ConsumeResource("paper", self.PaperDrain)
	end
end

function ENT:Think()
	local power = self:FWHaveResource("power") -- Current power input to printer.
	local paper = self:FWHaveResource("paper")

	if self:GetNextPrintTime() < CurTime() and (power and power >= self.PowerRequired) and (paper and paper + 1 > self.PaperDrain) and self:GetPrintStatus() then
		fw.economy.createMoneyBag(self.PrintAmount, self:LocalToWorld(self:OBBMaxs() + Vector(4, -3.5, -3)))
		self:SetNextPrintTime(CurTime() + self.PrintSpeed)
		self:FWSetResource("paper", 0)

		fw.hud.pushNotification(self:FWGetOwner(), self.PrintName or 'Money Printer', 'Printed $' .. self.PrintAmount, Color(0, 255, 0))
		if not self:ConsumeResource('paper', self.PaperDrain) then
			fw.hud.pushNotification(self:FWGetOwner(), self.PrintName, 'Is out of paper!', Color(255, 0, 0))
		end
	elseif not (power and power >= self.PowerRequired) or not (paper and paper + 1 > self.PaperDrain) then
		if self:GetPrintStatus() ~= false then
			self:SetPrintStatus(false)
			self.Sound:Stop()
		end
	elseif not self:GetPrintStatus() then
		self:SetPrintStatus(true)
		self:SetNextPrintTime(CurTime() + self.PrintSpeed)
		self.Sound:Play()
	end
end

function ENT:OnRemove()
	self.Sound:Stop()
	fw.resource.removeEntity(self)
end
