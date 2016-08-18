if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Raw Resource Extractor"
ENT.Author      = "crazyscouter"
ENT.Category    = "Faction Wars"

ENT.Color = color_white
ENT.ExtractInterval = 25
ENT.MaxConsumption = {
	["power"] = 2,
}
ENT.MaxStorage = {
	["raw_resources"] = 30,
}
ENT.NETWORK_SIZE = 500
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "On")
end

if SERVER then
	util.AddNetworkString("fw.turnExOn")
	util.AddNetworkString("fw.spawnOre")


	net.Receive("fw.turnExOn", function(l, ply)
		local ext = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		--if (IsValid(ent) and ent:GetClass() == "fw_fermentation_tank" and tr.HitPos:GetPos():DistToSqr(ply:GetPos()) < 30000) then
			ext:SetOn(not ext:GetOn())
	--	end
	end)

	net.Receive("fw.spawnOre", function(l, ply)
		local ext = net.ReadEntity()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if (IsValid(ent) and ent:GetClass() == "fw_fermentation_tank" and tr.HitPos:DistToSqr(ply:GetPos()) < 30000) then
			ext:CreateAlcohol()
		end
	end)

	function ENT:Initialize()
		self:SetModel("models/props_combine/combinethumper002.mdl")
		--TODO: UNCOMMENT THIS LINE
		--self:SetModelScale(.5)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()

		self.Consumes = {
			["power"] = self.MaxConsumption.power,
		}
		self.Storage = {
			["raw_resources"] = 0,
		}
		fw.resource.addEntity(self)

		self._timerName = "extractor-" .. self:EntIndex()
		self:SetNextExtractTime(self.ExtractInterval * 1.5)
	end

	function ENT:CanExtract()
		return self.Storage.raw_resources < self.MaxStorage.raw_resources and self:FWHaveResource("power") >= self.Consumes["power"]
	end

	function ENT:SetNextExtractTime(timeInSeconds)
		timer.Create(self._timerName, timeInSeconds, 1, function()
			if self:CanExtract() then
				self.Storage["raw_resources"] = self.Storage["raw_resources"] + 2
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
		elseif (self:GetOn() and not self:CanExtract()) then
			--self:SetOn(false)
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
		return Vector(obbcenter.x - 8, obbmax.y, obbcenter.z), Angle(0, -90, 90), 0.15
	end

	function ENT:CustomUI(panel)
		local row = vgui.Create("fwEntityInfoRow", panel)
		row:SetTall(fw.resource.INFO_ROW_HEIGHT)

		local status = vgui.Create("FWUITextBox", row)
		status:SetAlign("center")
		status:Dock(FILL)

		row:SetRefresh(function(memory)
			if memory.power ~= self:FWHaveResource("power") then
				memory.power = self:FWHaveResource("power")
				return true -- will trigger the next function... refresh to get called
			end
			if memory.raw_resources == self.MaxStorage.raw_resources then
				memory.raw_resources = self.MaxStorage.raw_resources
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
			elseif self:FWGetResourceInfo().amStoring.raw_resources == self.MaxStorage.raw_resources then
				status:SetText("MAX STORAGE REACHED")
				status:SetColor(Color(255, 0, 0))
			elseif (not self:GetOn()) then
				status:SetText('EXTRACTOR IS OFF')
				status:SetColor(Color(255, 0, 0))
			else
				status:SetText("EXTRACTING ORE")
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

		local alc = vgui.Create("FWUIButton", panel)
		alc:SetTall(fw.resource.INFO_ROW_HEIGHT)
		alc:SetFont(fw.fonts.default)
		alc:SetText("Package Ore")
		alc:SetEnabled(false)

		alc.DoClick = function()
			net.Start("fw.spawnOre")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end

end
