if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Fermentation Tank"
ENT.Author      = "thelastpenguin"
ENT.Category    = "Faction Wars"

ENT.Color = color_white
ENT.BrewInterval = 60
ENT.MaxConsumption = {
	["power"] = 2,
	["water"] = 4,
}
ENT.MaxStorage = {
	['alcohol'] = 25,
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
			['power'] = 1,
		}
		self.Storage = {
			['alcohol'] = 0,
		}
		fw.resource.addEntity(self)

		self._timerName = 'fermentation-tank-' .. self:EntIndex()
		self:SetNextBrewTime(self.BrewInterval * 1.5)
	end

	function ENT:FillupWaterCache()
		local haveWater = self:FWHaveResource('water')
		if haveWater < self.MaxConsumption.water then
			self:ConsumeResource('water', self.MaxConsumption.water)
		end
	end

	function ENT:SetNextBrewTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:FWHaveResource('water') >= self.MaxConsumption.water and self.Storage.alcohol < self.MaxStorage.alcohol then
				-- TODO: notify the player that their printer produced a money bag
				self:FWSetResource('water', 0)
				self.Storage['alcohol'] = self.Storage['alcohol'] + 1
			end
			self:SetNextBrewTime(self.BrewInterval)
		end)
	end

	function ENT:OnResourceUpdate()
		self:FillupWaterCache()
		if self:FWHaveResource("power") < self.Consumes['power'] then
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
		local row = vgui.Create('fwEntityInfoPanel', panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create('FWUITextBox', row)
		status:SetAlign('center')
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if memory.power ~= self:FWHaveResource('power') then
				memory.power = self:FWHaveResource('power')
				return true -- will trigger the next function... refresh to get called
			end
			if memory.water ~= self:FWHaveResource('water') then
				memory.water = self:FWHaveResource('water')
				return true
			end
		end, function()
			if self:FWHaveResource('power') < self.MaxConsumption.power then
				status:SetText('NOT ENOUGH POWER')
				status:SetColor(Color(255, 0, 0))
			elseif self:FWHaveResource('water') < self.MaxConsumption.water then
				status:SetText('NOT ENOUGH WATER')
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText('FERMENTING')
				status:SetColor(Color(0, 255, 0))
			end
		end)
	end

end
