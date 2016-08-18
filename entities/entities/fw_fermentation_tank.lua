if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Fermentation Tank"
ENT.Author      = "crazyscouter, thelastpenguin"
ENT.Category    = "Faction Wars"

ENT.Color = color_white
ENT.BrewInterval = 30
ENT.MaxConsumption = {
	["power"] = 1.5,
	["water"] = 4,
}
ENT.MaxStorage = {
	['alcohol'] = 1,
}
ENT.NETWORK_SIZE = 500

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "On")
end


if SERVER then
	util.AddNetworkString("fw.turnTankOn")
	util.AddNetworkString("fw.spawnAlcohol")


	net.Receive("fw.turnTankOn", function(l, ply)
		local tank = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_fermentation_tank" and tr.HitPos:DistToSqr(ply:GetPos()) < 30000) then
			tank:SetOn(not tank:GetOn())
		end
	end)

	net.Receive("fw.spawnAlcohol", function(l, ply)
		local tank = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_fermentation_tank" and  tr.HitPos:DistToSqr(ply:GetPos()) < 30000) then
			tank:CreateAlcohol()
		end
	end)

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/laundry_basket001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
		self:PhysWake()

		local ang = self:GetAngles()
		self:SetAngles(Angle(0, ang.y, 180))

		self.shaft = ents.Create("prop_physics")
		self.shaft:SetModel("models/hunter/tubes/tubebend4x4x90.mdl")
		self.shaft:SetModelScale(.1)
		self.shaft:SetParent(self)
		self.shaft:SetMaterial("phoenix_storms/metalfloor_2-3")

		local pos = self:GetPos() + self:GetAngles():Right() * 33 + Vector(0, 0, self:OBBMaxs().z - self.shaft:OBBMaxs().z - 4)
		self.shaft:SetPos(pos)

		local ang = self:GetAngles() + Angle(180, 0, 0)
		self.shaft:SetAngles(ang)

		if self.Color then
			self:SetColor(self.Color)
		end
		if self.Material then
			self:SetMaterial(self.Material)
		end

		self.Consumes = {
			['power'] = self.MaxConsumption.power,
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
			local succ = self:ConsumeResource('water', self.MaxConsumption.water)
		end
	end

	function ENT:CanBrew()
		return self:FWHaveResource('water') >= self.MaxConsumption.water and self.Storage.alcohol < self.MaxStorage.alcohol
	end

	function ENT:SetNextBrewTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:CanBrew() and self:GetOn() then

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

	function ENT:HasDistillery()
		return IsValid(self.distillery)
	end

	function ENT:CreateAlcohol()
		if (self.Storage.alcohol == self.MaxStorage.alcohol) then
			local bottle = ents.Create("fw_alcohol_6pack")
			bottle:SetPos(self.shaft:GetPos() - Vector(0, 0, 20))
			bottle:Spawn()
			bottle:Activate()

			self.Storage.alcohol = 0
		end
	end

	function ENT:DoEffect()
		local data = EffectData()
		local hasDist = self:HasDistillery()
		local pos = hasDist and Vector(0, 0, 100) or Vector(0, 0, 20)

		data:SetOrigin(self:GetPos() + pos)

		for i=1, 8 do
			util.Effect("WheelDust", data)
		end

		self:EmitSound("ambient/water/water_splash3.wav", 75, 100, .2)
	end

	function ENT:Think()
		local ang = self:GetAngles()
		self:SetAngles(Angle(0, ang.y, 180))

		if (self:GetOn() and self:CanBrew()) then
			local last = self.last_effect or 0

			if (CurTime() - last >=1) then
				self.last_effect = CurTime()

				self:DoEffect()
			end
		end
	end

	function ENT:Touch(toucher)
		if (toucher:GetClass() == "fw_distillery") then

			toucher:SetAngles(self:GetAngles() + Angle(0, 0, 180))

			local right = self:GetAngles():Right() * 33

			toucher:SetPos(self:GetPos() + -right + Vector(0, 0, 21))
			toucher:SetParent(self)
			toucher:SetSolid(SOLID_VPHYSICS)

			self.distillery = toucher
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
		return Vector(obbcenter.x + 26, obbmax.y - 25, obbcenter.z), Angle(180, 90, 90), 0.2
	end


	function ENT:CustomUI(panel)
		local ent = self
		local row = vgui.Create('fwEntityInfoRow', panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create('FWUITextBox', row)
		status:SetAlign('center')
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if (not IsValid(ent)) then return end

			if memory.power ~= ent:FWHaveResource('power') then
				memory.power = ent:FWHaveResource('power')
				return true -- will trigger the next function... refresh to get called
			end
			if memory.water ~= ent:FWHaveResource('water') then
				memory.water = ent:FWHaveResource('water')
				return true
			end
			if memory.alcohol == ent.MaxStorage.alcohol then
				memory.alcohol = ent.MaxStorage.alcohol
				return true
			end
			if memory.status ~= ent:GetOn() then
				memory.status = ent:GetOn()
				return true
			end
		end, function()
			if ent:FWHaveResource('power') < ent.MaxConsumption.power then
				status:SetText('NOT ENOUGH POWER')
				status:SetColor(Color(255, 0, 0))
			elseif ent:FWHaveResource('water') < ent.MaxConsumption.water then
				status:SetText('NOT ENOUGH WATER')
				status:SetColor(Color(255, 0, 0))
			elseif ent:FWGetResourceInfo().amStoring.alcohol == ent.MaxStorage.alcohol then
				status:SetText('MAX STORAGE REACHED')
				status:SetColor(Color(255, 0, 0))
			elseif (not ent:GetOn()) then
				status:SetText('FERMENTER IS OFF')
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText('FERMENTING')
				status:SetColor(Color(0, 255, 0))
			end
		end)

		local button = vgui.Create("FWUIButton", panel)
		button:SetTall(fw.resource.INFO_ROW_HEIGHT)
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
			net.Start("fw.turnTankOn")
				net.WriteEntity(self)
			net.SendToServer()
		end

		local alc = vgui.Create("FWUIButton", panel)
		alc:SetTall(fw.resource.INFO_ROW_HEIGHT)
		alc:SetText("Bottle Alcohol")
		alc:SetEnabled(false)

		alc.DoClick = function()
			net.Start("fw.spawnAlcohol")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end

end
