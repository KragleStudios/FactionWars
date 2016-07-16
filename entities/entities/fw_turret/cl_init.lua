include("shared.lua")
include("3d2dvgui.lua")

local form = nil
local function createMenu()
	form = vgui.Create("DFrame")
	form:SetPos(0, 0)
	form:SetSize(200, 200)
	form:SetTitle(" ")
	form:ShowCloseButton(true)
	form:SetVisible(false)

	local on = true

	local toggle = vgui.Create("DButton", form)
	toggle:SetSize((form:GetWide() / 2) - 30, (form:GetTall() / 2) - 30)
	toggle:SetText(on and "On" or "Off")
	function toggle:DoClick()
		net.Start("fw.updateTurretStatus")
			net.WriteEntity(ENT)
			net.WriteBool(not on)
		net.SendToServer()
	end
end

function ENT:Draw()
	self:DrawModel()
	on = self:GetStatus()

	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then
		return 
	end

	if (not form) then
		createMenu()
	end

	form:SetVisible(true)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 45)
	--ang:RotateAroundAxis(ang:Right(), 90)

	--TODO: FIX POSITIONING !!!!!
	local pos = self:WorldToLocal(self:GetPos() + Vector(-10, 10, 20))
	pos = self:LocalToWorld(pos)

	vgui.Start3D2D(pos, ang, .09)
		form:Paint3D2D()
	vgui.End3D2D()
end