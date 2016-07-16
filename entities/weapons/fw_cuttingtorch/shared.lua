if SERVER then
	SWEP.Weight = 1
 
elseif CLIENT then 

	SWEP.PrintName = "Cutting Torch"

	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true

end
 
SWEP.Author = "Spai"
SWEP.Purpose = "Cut through the props"
SWEP.Instructions = "Left Click to cut"
 
 
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
 
SWEP.ViewModel = "models/weapons/v_IRifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Power = 10

function SWEP:Reload()
	
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local tr = self.Owner:GetEyeTrace()
	if tr.Entity:GetClass() == "prop_physics" and tr.HitPos:Distance(tr.StartPos) <= 100 then
		self.Weapon:EmitSound("Weapon_StunStick.Activate")
		if SERVER then
			tr.Entity:TakeDamage(self.Primary.Power , self.Owner, self)
		else
			self:DoImpactEffect(tr)
		end
	end
end

function SWEP:DoImpactEffect(tr)
	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "AR2Impact", effectdata )
	util.Effect ("ManhackSparks", effectdata)
end

function SWEP:Think()

end

function SWEP:DrawHUD()
	if LocalPlayer():GetEyeTrace().Entity:GetClass() != "prop_physics" then return end

	surface.SetDrawColor(32, 32, 32, 230)
	surface.DrawRect(ScrW() * .5 - 200, 200, 400, 20)

	local pcnt = LocalPlayer():GetEyeTrace().Entity:getHealth() / LocalPlayer():GetEyeTrace().Entity:getMaxHealth() * 100
	surface.SetDrawColor((100 - pcnt) * 2.5, pcnt * 2.5, 0)
	surface.DrawRect(ScrW() * .5 - 200, 200, math.Clamp( pcnt * 4, 0, 400), 20)
	
	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(ScrW() * .5 - 200, 200, 400, 20)
end
