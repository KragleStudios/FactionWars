AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end

	self:SetTrigger(true)

	self:SetNextPrintTime(CurTime() + self.PrintSpeed)
	self:SetMoney(0)
	self:SetPaper(0)
	-- self:SetInk(0)
	self:SetPrintStatus(true)

	self:SetColor(self.Color)

	self.Sound = CreateSound(self, "ambient/levels/labs/equipment_printer_loop1.wav")
	self.Sound:SetSoundLevel(57)
end

function ENT:Use(activator, ply)
	local money = self:GetMoney()
	if money > 0 then
		ply:addMoney(money)
		self:SetMoney(0)
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars]: ", Color(255, 255, 255), "You collected $" .. money .. " from a money printer.")
	end
end

function ENT:Think()
	self.Power = math.huge -- Current power input to printer. Replace with function that gets power input when system is added.

	if self:GetNextPrintTime() < CurTime() and self.Power >= self.PowerRequired --[[and self:GetInk() + 1 > self.InkDrain]] and self:GetPaper() + 1 > self.PaperDrain and self:GetPrintStatus() then
		-- self:SetMoney(self:GetMoney() + self.PrintAmount)
		local money = ents.Create("fw_money")
		money:SetPos(self:LocalToWorld(self:OBBMaxs() + Vector(4, -3.5, -3)))
		money:SetValue(self.PrintAmount)
		money:Spawn()

		self:SetNextPrintTime(CurTime() + self.PrintSpeed)
		self:SetPaper(self:GetPaper() - self.PaperDrain)
		-- self:SetInk(self:GetInk() - self.InkDrain)
	elseif self.Power < self.PowerRequired --[[or self:GetInk() + 1 <= self.InkDrain]] or self:GetPaper() + 1 <= self.PaperDrain then
		self:SetPrintStatus(false)
		self.Sound:Stop()
	elseif not self:GetPrintStatus() then
		self:SetPrintStatus(true)
		self:SetNextPrintTime(CurTime() + self.PrintSpeed)
		self.Sound:Play()
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_printer_paper" and self:GetPaper() < self.PaperCap and not ent.Used then
		ent.Used = true
		ent:Remove()
		self:SetPaper(math.Clamp(self:GetPaper() + 15, 0, self.PaperCap))
--[[elseif ent:GetClass() == "fw_printer_ink" and self:GetInk() < 100 and not ent.Used then
		ent.Used = true
		ent:Remove()
		self:SetInk(self:GetInk() + 30)]]
	end
end

function ENT:OnRemove()
	self.Sound:Stop()
end
