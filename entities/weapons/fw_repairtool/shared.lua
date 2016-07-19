SWEP.PrintName = "Repair Tool"
SWEP.Base = "weapon_base"

SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"

SWEP.UseHands = true

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"

SWEP.Sparks = 0
SWEP.Sound = Sound("ambient/energy/spark5.wav")

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 100,
		filter = function(ent) return ent != self.Owner end
	})

	if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_physics" then
		if SERVER then
			if tr.Entity:getMaxHealth() > tr.Entity:getHealth() then
				tr.Entity:setHealth(tr.Entity:getHealth() + 0.5)
			end

			if tr.Entity:getHealth() > tr.Entity:getMaxHealth() / 2 then
				tr.Entity:SetColor(Color(255, 255, 255, 255))
				tr.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
			end
		end

		if self.Sparks % 8 == 0 then
			local effect = EffectData()
			effect:SetOrigin(tr.HitPos)
			effect:SetNormal(tr.HitNormal)
			util.Effect("ManhackSparks", effect)
			self:EmitSound(self.Sound)
		end

		self.Sparks = self.Sparks + 1
	end

	--self:EmitSound()
end

function SWEP:SecondaryAttack()

end