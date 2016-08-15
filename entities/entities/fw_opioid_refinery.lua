if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Opioid Refinery"
ENT.Author      = "crazyscouter"
ENT.Category    = "Faction Wars"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Color = color_white
ENT.CreateTime = 15
ENT.MaxConsumption = {
	["power"] = 2,
	["water"] = 2,
	["raw_resources"] = 1,
}
ENT.MaxStorage = {
	['opioid'] = 25,
}
ENT.NETWORK_SIZE = 500

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 2, "On")
end

if SERVER then
	util.AddNetworkString("fw.turnRefineOn")
	util.AddNetworkString("fw.spawnOpioid")


	net.Receive("fw.turnRefineOn", function(l, ply)
		local ref = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_opioid_refinery" and ent:GetPos():DistToSqr(ply:GetPos()) < 30000) then
			ref:SetOn(not ref:GetOn())
		end
	end)

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/laundry_washer001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
		self:PhysWake()

		self.Consumes = {
			['power'] = self.MaxConsumption.power,
		}
		self.Storage = {
			['opioid'] = 0,
		}
		fw.resource.addEntity(self)

		self._timerName = 'refine-tank-' .. self:EntIndex()
		self:SetNextCreate(self.CreateTime * 1.5)
	end

	function ENT:FillupResourceCache()
		local haveWater = self:FWHaveResource('water')
		local haveRes = self:FWHaveResource('raw_resources')

		if haveWater < self.MaxConsumption.water then
			local succ = self:ConsumeResource('water', self.MaxConsumption.water)
		end
		if haveRes < self.MaxConsumption.raw_resources then
			local succ = self:ConsumeResource('raw_resources', self.MaxConsumption.raw_resources)
		end

	end

	function ENT:CanCreate()
		return self:FWHaveResource('water') >= self.MaxConsumption.water and self:FWHaveResource('raw_resources') >= self.MaxConsumption.raw_resources and self.Storage.opioid < self.MaxStorage.opioid
	end

	function ENT:SetNextCreate(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:CanCreate() and self:GetOn() then

				self:FWSetResource('raw_resources', 0)
				self:FWSetResource('water', 0)
				self.Storage['opioid'] = self.Storage['opioid'] + 1
			end
			self:SetNextCreate(self.CreateTime)
		end)
	end

	function ENT:OnResourceUpdate()
		self:FillupResourceCache()
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

	function ENT:CreateOpioid()
		if (not IsValid(self:GetParent())) then return end
		if (self.Storage.opioid >= 5) then
			local par = self:GetParent()
			local pos = par.shaft:GetPos()

			local bottle = ents.Create("fw_opioid")
			bottle:SetPos(pos - Vector(0, 0, 20))
			bottle:Spawn()
			bottle:Activate()

			self.Storage.opioid = self.Storage.opioid - 5
		end
	end

	function ENT:DoEffect()
		local data = EffectData()
		local pos = self:GetPos() + Vector(0, 0, 20)

		data:SetOrigin(pos)

		for i=1, 8 do
			util.Effect("WheelDust", data)
		end

		self:EmitSound("ambient/water/water_splash3.wav", 75, 100, .2)
	end

	function ENT:Think()

		if (self:GetOn() and self:CanCreate()) then
			local last = self.last_effect or 0

			if (CurTime() - last >= 1) then
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
		return Vector(obbcenter.x + 40, obbcenter.y, obbcenter.z), Angle(0, 90, 90), 0.2
	end


	function ENT:CustomUI(panel)
		local ent = self
		local row = vgui.Create('fwEntityInfoPanel', panel)
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
			if memory.opioid == ent.MaxStorage.opioid then
				memory.opioid = ent.MaxStorage.opioid
				return true
			end
			if memory.raw_resources ~= ent.MaxStorage.raw_resources then
				memory.raw_resources = ent.MaxStorage.raw_resources
				return true
			end
			if memory.water ~= ent.MaxStorage.water then
				memory.water = ent.MaxStorage.water
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
			elseif ent:FWGetResourceInfo().amStoring.opioid == ent.MaxStorage.opioid then
				status:SetText('MAX STORAGE REACHED')
				status:SetColor(Color(255, 0, 0))
			elseif ent:FWHaveResource('water') < ent.MaxConsumption.water then
				status:SetText('NOT ENOUGH WATER')
				status:SetColor(Color(255, 0, 0))
			elseif ent:FWHaveResource('raw_resources') < ent.MaxConsumption.raw_resources then
				status:SetText('NOT ENOUGH RAW RESOURCES')
				status:SetColor(Color(255, 0, 0))
			elseif (not ent:GetOn()) then
				status:SetText('REFINERY IS OFF')
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText('REFINING')
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
			net.Start("fw.turnRefineOn")
				net.WriteEntity(self)
			net.SendToServer()
		end

	end

end

