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
	-- self:SetInk(0)
	self:SetPrintStatus(true)

	self:SetColor(self.Color)

	self.Sound = CreateSound(self, "ambient/levels/labs/equipment_printer_loop1.wav")
	self.Sound:SetSoundLevel(57)

	self.Consumes = {
		['power'] = self.PowerRequired,
	}

	fw.resource.addEntity(self)
end

function ENT:Think()
	self.Power = self:FWHaveResource("power") -- Current power input to printer.

	if self:GetNextPrintTime() < CurTime() and self.Power >= self.PowerRequired --[[and self:GetInk() + 1 > self.InkDrain]] and self:GetPaper() + 1 > self.PaperDrain and self:GetPrintStatus() then
		-- self:SetMoney(self:GetMoney() + self.PrintAmount)
		local money = ents.Create("fw_money")
		money:SetPos(self:LocalToWorld(self:OBBMaxs() + Vector(4, -3.5, -3)))
		money:SetValue(self.PrintAmount)
		money:Spawn()

		self:SetNextPrintTime(CurTime() + self.PrintSpeed)
		self:SetPaper(self:GetPaper() - self.PaperDrain)
		-- self:SetInk(self:GetInk() - self.InkDrain)
	elseif not self.Power >= self.PowerRequired --[[or self:GetInk() + 1 <= self.InkDrain]] or self:GetPaper() + 1 <= self.PaperDrain then
		self:SetPrintStatus(false)
		self.Sound:Stop()
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
