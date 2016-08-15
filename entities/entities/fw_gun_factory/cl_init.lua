include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	self:FWDrawInfo()
end

function ENT:GetDisplayPosition()
	local obbcenter = self:OBBCenter()
	local obbmax = self:OBBMaxs()
	return Vector(obbcenter.x, obbmax.y, obbcenter.z + 5), Angle(180, 0, -90), 0.15
end

function ENT:CustomUI(panel)
	local row = vgui.Create('fwEntityInfoPanel', panel)
	row:SetTall(fw.resource.INFO_ROW_HEIGHT)

	row:SetRefresh(function(memory)
		if memory.power ~= self:FWHaveResource('power') then
			memory.power = self:FWHaveResource('power')
			return true -- will trigger the next function... refresh to get called
		end
		if memory.parts ~= self:FWHaveResource('parts') then
			memory.paper = self:FWHaveResource('parts')
			return true
		end
		if memory.scrap ~= self:FWHaveResource('scrap') then
			memory.scrap = self:FWHaveResource('scrap')
			return true
		end
	end, function() end)

	local pistol = vgui.Create("FWUIButton", panel)
	pistol:Dock(TOP)
	pistol:SetText("Produce Pistol")
	pistol.DoClick = function()
		net.Start("Fac_ProduceGun")
		net.WriteEntity(self)
		net.WriteUInt(0, 4)
		net.SendToServer()
	end

	local smg = vgui.Create("FWUIButton", panel)
	smg:Dock(TOP)
	smg:SetText("Produce SMG")
	smg.DoClick = function()
		net.Start("Fac_ProduceGun")
		net.WriteEntity(self)
		net.WriteUInt(1, 4)
		net.SendToServer()
	end

	local twohanded = vgui.Create("FWUIButton", panel)
	twohanded:Dock(TOP)
	twohanded:SetText("Produce Two-Handed weapon")
	twohanded.DoClick = function()
		net.Start("Fac_ProduceGun")
		net.WriteEntity(self)
		net.WriteUInt(2, 4)
		net.SendToServer()
	end

	local sniper = vgui.Create("FWUIButton", panel)
	sniper:Dock(TOP)
	sniper:SetText("Produce Sniper Rifle")
	sniper.DoClick = function()
		net.Start("Fac_ProduceGun")
		net.WriteEntity(self)
		net.WriteUInt(3, 4)
		net.SendToServer()
	end
end
