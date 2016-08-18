if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Oil Extractor "
ENT.Author      = "crazyscouter"
ENT.Category    = "Faction Wars"

ENT.Color = color_white
ENT.ExtractInterval = 25
ENT.MaxConsumption = {
	["power"] = 2,
}
ENT.MaxStorage = {
	["gas"] = 200,
}
ENT.NETWORK_SIZE = 500
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "On")
end

if SERVER then
	util.AddNetworkString("fw.turnOilOn")


	net.Receive("fw.turnExOn", function(l, ply)
		local ext = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		--if (IsValid(ent) and ent:GetClass() == "fw_fermentation_tank" and tr.HitPos:GetPos():DistToSqr(ply:GetPos()) < 30000) then
			ext:SetOn(not ext:GetOn())
		--end
	end)

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/gaspump001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()

		self.Consumes = {
			["power"] = self.MaxConsumption.power,
		}
		self.Storage = {
			["gas"] = 0,
		}
		fw.resource.addEntity(self)

		self._timerName = "gas-extractor-" .. self:EntIndex()
		self:SetNextExtractTime(self.ExtractInterval * 1.5)
	end

	function ENT:CanExtract()
		return self.Storage.gas < self.MaxStorage.gas and self:FWHaveResource("power") >= self.Consumes["power"]
	end

	function ENT:SetNextExtractTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:CanExtract() then
				self.Storage["gas"] = self.Storage["gas"] + 4
			end
			self:SetNextExtractTime(self.ExtractInterval)
		end)
	end

	function ENT:OnResourceUpdate()
		if self:FWHaveResource("power") < self.Consumes["power"] then
			timer.Pause(self._timerName)
		else
			timer.UnPause(self._timerName)
		end
	end

	function ENT:OnRemove()
		timer.Destroy(self._timerName)
		fw.resource.removeEntity(self)
	end

	function ENT:DoEffect()

	end

	function ENT:Think()
		if (self:GetOn() and self:CanExtract()) then
			local last = self.last_effect or 0

			if (CurTime() - last >=1) then
				self.last_effect = CurTime()

				self:DoEffect()
			end
		end
	end

else
	function ENT:Draw()
		self:DrawModel()
		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x + 15, 0, obbcenter.z), Angle(0, 90, 90), 0.15
	end

	function ENT:CustomUI(panel)
		local row = vgui.Create("fwEntityInfoRow", panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create("FWUITextBox", row)
		status:SetAlign("center")
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if (not IsValid(self)) then return false end

			if memory.power ~= self:FWHaveResource("power") then
				memory.power = self:FWHaveResource("power")
				return true -- will trigger the next function... refresh to get called
			end
			if memory.gas == self.MaxStorage.gas then
				memory.gas = self.MaxStorage.gas
				return true
			end
			if memory.status ~= self:GetOn() then
				memory.status = self:GetOn()
				return true
			end
		end, function()
			if self:FWHaveResource("power") < self.MaxConsumption.power then
				status:SetText("NOT ENOUGH POWER")
				status:SetColor(Color(255, 0, 0))
			elseif self:FWGetResourceInfo().amStoring.gas == self.MaxStorage.gas then
				status:SetText("MAX STORAGE REACHED")
				status:SetColor(Color(255, 0, 0))
			elseif (not self:GetOn()) then
				status:SetText('EXTRACTOR IS OFF')
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText("EXTRACTING OIL -> GAS")
				status:SetColor(Color(0, 255, 0))
			end
		end)

		local button = vgui.Create("FWUIButton", panel)
		button:SetTall(fw.resource.INFO_ROW_HEIGHT)
		button:SetFont(fw.fonts.default)
		button.Think = function(pnl)
			if (not IsValid(self)) then return end

			local on = self:GetOn()
			if (button.on != on) then
				button:SetText(on and "Turn Off" or "Turn On")
				button:PerformLayout()

				button.on = on
			end
		end

		button.DoClick = function()
			net.Start("fw.turnExOn")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end

end
