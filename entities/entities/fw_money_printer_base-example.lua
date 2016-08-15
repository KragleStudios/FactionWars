if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Money Printer Base"
ENT.Author      = "thelastpenguin"
ENT.Category    = "Faction Wars"

ENT.Color = color_white
ENT.PowerRequired = 2
ENT.PrintAmount = 200
ENT.PrintInterval = 10
ENT.MaxConsumption = {
	["power"] = 2,
	["paper"] = 2,
}
ENT.NETWORK_SIZE = 500

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.PrinterModel or "models/props_c17/consolebox01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()

		if self.Color then
			self:SetColor(self.Color)
		end
		if self.Material then
			self:SetMaterial(self.Material)
		end

		self.Consumes = {
			["power"] = self.PowerRequired,
		}
		fw.resource.addEntity(self)

		self._timerName = "money-printer-" .. self:EntIndex()
		self:SetNextPrintTime(self.PrintInterval * 1.5)
	end

	function ENT:FillupPaperCache()
		local havePaper = self:FWHaveResource("paper")
		if havePaper < self.MaxConsumption.paper then
			local succ = self:ConsumeResource("paper", self.MaxConsumption.paper)
		end
	end

	function ENT:SetNextPrintTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:FWHaveResource("paper") >= self.MaxConsumption.paper then
				-- TODO: notify the player that their printer produced a money bag
				self:FWSetResource("paper", 0)
				self:FWSetResource("alcohol", self:FWGetResource("alcohol") + 1)
			end
			self:SetNextPrintTime(self.PrintInterval)
		end)
	end

	function ENT:OnResourceUpdate()
		self:FillupPaperCache()
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

else
	function ENT:Draw()
		self:DrawModel()
		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x, obbcenter.y, obbmax.z), Angle(0, 90, 0), 0.15
	end

	function ENT:CustomUI(panel)
		local row = vgui.Create("fwEntityInfoPanel", panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create("FWUITextBox", row)
		status:SetAlign("center")
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if memory.power ~= self:FWHaveResource("power") then
				memory.power = self:FWHaveResource("power")
				return true -- will trigger the next function... refresh to get called
			end
			if memory.paper ~= self:FWHaveResource("paper") then
				memory.paper = self:FWHaveResource("paper")
				return true
			end
		end, function()
			if self:FWHaveResource("power") < self.MaxConsumption.power then
				status:SetText("NOT ENOUGH POWER")
				status:SetColor(Color(255, 0, 0))
			elseif self:FWHaveResource("paper") < self.MaxConsumption.paper then
				status:SetText("NOT ENOUGH PAPER")
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText("PRINTER RUNNING")
				status:SetColor(Color(0, 255, 0))
			end
		end)
	end

end
