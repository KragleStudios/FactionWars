if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Distillery"
ENT.Author      = "crazyscouter"
ENT.Category    = "Faction Wars"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Color = color_white
ENT.BrewInterval = 15
ENT.MaxConsumption = {
	["power"] = 1,
	["alcohol"] = 1,
}
ENT.MaxStorage = {
	["vodka"] = 25,
}
ENT.NETWORK_SIZE = 500

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 2, "On")
end

if SERVER then
	util.AddNetworkString("fw.turnDistOn")
	util.AddNetworkString("fw.spawnVodka")

	net.Receive("fw.turnDistOn", function(l, ply)
		local dist = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_distillery" and ent:GetPos():DistToSqr(ply:GetPos()) < 30000) then
			dist:SetOn(not dist:GetOn())
		end
	end)

	net.Receive("fw.spawnVodka", function(l, ply)
		local dist = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_distillery" and ent:GetPos():DistToSqr(ply:GetPos()) < 30000) then
			dist:CreateAlcohol()
		end
	end)

	function ENT:Initialize()
		self:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
		self:PhysWake()

		if self.Color then
			self:SetColor(self.Color)
		end
		if self.Material then
			self:SetMaterial(self.Material)
		end

		self.Consumes = {
			["power"] = self.MaxConsumption.power,
		}
		self.Storage = {
			["vodka"] = 0,
		}
		fw.resource.addEntity(self)

		self._timerName = "distillery-tank-" .. self:EntIndex()
		self:SetNextBrewTime(self.BrewInterval * 1.5)
	end

	function ENT:FillupAlcoholCache()
		local haveAlcohol = self:FWHaveResource("alcohol")
		if haveAlcohol < self.MaxConsumption.alcohol then
			local succ = self:ConsumeResource("alcohol", self.MaxConsumption.alcohol)
		end
	end

	function ENT:CanBrew()
		return self:FWHaveResource("alcohol") >= self.MaxConsumption.alcohol and self.Storage.vodka < self.MaxStorage.vodka
	end

	function ENT:SetNextBrewTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:CanBrew() and self:GetOn() then

				self:FWSetResource("alcohol", 0)
				self.Storage["vodka"] = self.Storage["vodka"] + 1
			end
			self:SetNextBrewTime(self.BrewInterval)
		end)
	end

	function ENT:OnResourceUpdate()
		self:FillupAlcoholCache()
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

	function ENT:HasDistillery()
		return IsValid(self.distillery)
	end

	function ENT:CreateAlcohol()
		if (not IsValid(self:GetParent())) then return end
		if (self.Storage.vodka >= 5) then
			local par = self:GetParent()
			local pos = par.shaft:GetPos()

			local bottle = ents.Create("fw_vodka")
			bottle:SetPos(pos - Vector(0, 0, 20))
			bottle:Spawn()
			bottle:Activate()

			self.Storage.vodka = self.Storage.vodka - 5
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
		return Vector(obbcenter.x + 26, -obbmax.y / 2 , obbcenter.z), Angle(0, 90, 90), 0.2
	end


	function ENT:CustomUI(panel)
		local ent = self
		local row = vgui.Create("fwEntityInfoPanel", panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create("FWUITextBox", row)
		status:SetAlign("center")
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if (not IsValid(ent)) then return end

			if memory.power ~= ent:FWHaveResource("power") then
				memory.power = ent:FWHaveResource("power")
				return true -- will trigger the next function... refresh to get called
			end
			if memory.vodka == ent.MaxStorage.vodka then
				memory.vodka = ent.MaxStorage.vodka
				return true
			end
			if memory.status ~= ent:GetOn() then
				memory.status = ent:GetOn()
				return true
			end
		end, function()
			if ent:FWHaveResource("power") < ent.MaxConsumption.power then
				status:SetText("NOT ENOUGH POWER")
				status:SetColor(Color(255, 0, 0))
			elseif ent:FWGetResourceInfo().amStoring.vodka == ent.MaxStorage.vodka then
				status:SetText("MAX STORAGE REACHED")
				status:SetColor(Color(255, 0, 0))
			elseif (not ent:GetOn()) then
				status:SetText("DiSTILLER IS OFF")
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText("DISTILLING")
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
			net.Start("fw.turnDistOn")
				net.WriteEntity(self)
			net.SendToServer()
		end

		local alc = vgui.Create("FWUIButton", panel)
		alc:SetTall(fw.resource.INFO_ROW_HEIGHT)
		alc:SetText("Bottle Vodka")
		alc:SetEnabled(false)

		alc.DoClick = function()
			net.Start("fw.spawnVodka")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end

end
