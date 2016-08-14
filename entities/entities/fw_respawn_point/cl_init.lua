include("shared.lua")

function ENT:InitializeVGUI()
	if IsValid(self._panel) then return end 

	local owner = self:FWGetOwner()
	local text = IsValid(owner) and (owner:Name() .. "'s") or "unknown's"
	local nickFont = fw.fonts.default_compact_shadow:fitToView(566, 75, text)
	local spawnpFont = fw.fonts.default_compact_shadow:fitToView(566, 75, "Spawn Point")
	local color = IsValid(owner) and fw.team.factions[owner:getFaction()].color or color_white

	local pnl = vgui.Create("DPanel")
	pnl:SetSize(580, 150)
	pnl.Paint = function(pnl, w, h)
		surface.SetDrawColor(40, 40, 50, 200)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(text, nickFont, w / 2, 75 / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Spawn Point", spawnpFont, w / 2, 75 + 75 / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(color)
		surface.DrawOutlinedRect(0, 0, w, h, color.r, color.g, color.b, 100)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2, color.r, color.g, color.b, 100)
	end

	self._panel = pnl
end

function ENT:Draw()
	self:DrawModel()
	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then return end

	if not IsValid(self._panel) then return end

	self._panel:Draw3D(self:GetPos() + self:GetUp() * 45, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.05)
end

function ENT:Initialize()
	self:InitializeVGUI()
end

function ENT:OnRemove()
	if IsValid(self._panel) then
		self._panel:Remove()
	end
end  
