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
	local header = vgui.Create("FWUITextBox", panel)
	header:SetText("OWNER")
	header:SetTall(18)
	header:SetInset(1)
	header:SetAlign("left")
	header.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end

	local owner = self:FWGetOwner()
	local ownerName = vgui.Create("FWUITextBox", panel)
	ownerName:SetText(IsValid(owner) and owner:Nick() or "Unknown")
	ownerName:SetTall(18)
	ownerName:SetInset(1)
	ownerName:SetAlign("left")
	ownerName.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end
end