if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Money Printer"
ENT.Author			= "thelastpenguin"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 500
ENT.Resources = true

ENT.MaxConsumption = {
	["power"] = 2,
}
ENT.PrintInterval = 30

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_c17/consolebox01a.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self.Consumes = {
			['power'] = 2,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Think()

	end

	function ENT:ScheduleNextPrint()
		timer.Simple(self.PrintInterval, function()
		end)
	end

	function ENT:OnRemove()
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
		end, function()
			if self:FWHaveResource('power') >= 2 then
				status:SetText('PRINTER RUNNING')
				status:SetColor(Color(0, 255, 0))
			else
				status:SetText('NOT ENOUGH POWER')
				status:SetColor(Color(255, 0, 0))
			end
		end)
	end

end
