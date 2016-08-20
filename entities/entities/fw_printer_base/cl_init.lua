include("shared.lua")

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
	local row = vgui.Create("fwEntityInfoRow", panel)
	row:SetTall(fw.resource.INFO_ROW_HEIGHT)

	local status = vgui.Create("FWUITextBox", row)
	status:SetAlign("center")
	status:Dock(FILL)
	status.Think = function()
		if not IsValid(self) then return end
		if self:GetPrintStatus() then
			status:SetText(math.floor(self:GetNextPrintTime() - CurTime()) .. "s to next print")
			status:SetColor(Color(0, 255, 0))
		end
	end

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
		if self:FWHaveResource("power") < self.PowerRequired then
			status:SetText("NO POWER")
			status:SetColor(Color(255, 0, 0))
		elseif self:FWHaveResource("paper") < self.PaperDrain then
			status:SetText("NO PAPER")
			status:SetColor(Color(255, 0, 0))
		end
	end)
end
