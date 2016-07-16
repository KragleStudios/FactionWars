include("shared.lua")

local dynCross = CreateConVar("fw_dynamic_crosshair", 1, FCVAR_ARCHIVE, "Enable/Disable dynamic crosshair")

local crosshairPos = {
	pos1 = 0,
	pos2 = 0,
	pos3 = 0,
	pos4 = 0
}

function SWEP:DoDrawCrosshair(x, y)
	if self.Scoped then return end
	if not IsValid(self.Owner) then return end

	local vel = 0
	local recoil = 0
	local spread = 0

	if dynCross:GetBool() then
		vel = math.abs(self.Owner:GetVelocity():Dot(self.Owner:GetForward())) / 10
		recoil = math.Clamp(self:GetCurrentRecoil(), 0, self.Primary.MaxRecoil / 2) * 1000 / 2
		spread = self.Primary.BaseSpread * 100
		if self.Owner:KeyDown(IN_DUCK) then recoil = recoil / 2 end
	end

	surface.SetDrawColor(Color(0, 255, 0))
	surface.DrawRect(crosshairPos.pos1, y - 1, 10, 2)
	surface.DrawRect(crosshairPos.pos2, y - 1, 10, 2)
	surface.DrawRect(x - 1, crosshairPos.pos3, 2, 10)
	surface.DrawRect(x - 1, crosshairPos.pos4, 2, 10)

	crosshairPos.pos1 = Lerp(0.1, crosshairPos.pos1, x + vel + recoil + spread)
	crosshairPos.pos2 = Lerp(0.1, crosshairPos.pos2, x - 10 - vel - recoil - spread)
	crosshairPos.pos3 = Lerp(0.1, crosshairPos.pos3, y + vel + recoil + spread)
	crosshairPos.pos4 = Lerp(0.1, crosshairPos.pos4, y - 10 - vel - recoil - spread)
end

function SWEP:DrawHUD()
	if self:GetScoped() then
		surface.SetTexture(surface.GetTextureID("sprites/scope"))
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawTexturedRect(ScrW() / 2 - ( ScrH() - 128 ) / 2, 64, ScrH() - 128, ScrH() - 128)

		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawRect(0, 0, ScrW() / 2 - (ScrH() - 128) / 2, ScrH())
		surface.DrawRect(ScrW() / 2 + (ScrH() - 128) / 2, 0, ScrW() / 2 - (ScrH() - 128) / 2, ScrH())
		surface.DrawRect(0, 0, ScrW(), 64)
		surface.DrawRect(0, ScrH() - 64, ScrW(), 64)

		surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())
		surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
	end
	self:DoDrawCrosshair(ScrW() / 2, ScrH() / 2)
end

function SWEP:HUDShouldDraw(name)
	if name == "CHudCrosshair" then return false end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetScoped() then
		return 0.22 -- Assuming players FOV is 90, 20/90 = 0.222222.... so our new sensitivty is that.
	end
end