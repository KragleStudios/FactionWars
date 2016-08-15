include("shared.lua")

function ENT:GetDisplayPosition()
  	local obbcenter = self:OBBCenter()
  	local obbmax = self:OBBMaxs()
  	return Vector(obbcenter.x, obbmax.y - 19.5, obbcenter.z + 41), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.2
end

function ENT:Draw()
  	self:DrawModel()
  	self:FWDrawInfo()
end

function ENT:CustomUI(panel)
	local owner = self:FWGetOwner()

	local header = vgui.Create("FWUITextBox", panel)
	header:SetText("OWNER: " .. (IsValid(owner) and owner:Nick() or 'unknown'))
	header:SetTall(fw.resource.INFO_ROW_HEIGHT)
	header:SetInset(1)
	header:SetAlign("left")
	header.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end
end
