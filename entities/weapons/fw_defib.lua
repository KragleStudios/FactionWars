SWEP.PrintName = "Defib"
SWEP.Base = "weapon_base"

SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.ViewModel = "models/weapons/c_medkit.mdl"

SWEP.Author = "crazyscouter"
SWEP.Instructions = "Charge with mouse 2\n Defib with mouse 1"
SWEP.HoldType = ""

SWEP.UseHands = true

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true

SWEP.ChargeSound = ""
SWEP.DefibFireSound = ""
SWEP.MaxCharge = 1500
SWEP.FireDistance = 100
SWEP.Money = 50
SWEP.FailRate = .33
SWEP.fireOffset = 5
SWEP.Damage = 25

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 1, "Charge")
	self:NetworkVar("Bool", 3, "Charging")
	self:NetworkVar("Bool", 2, "Charged")
	self:NetworkVar("Bool", 4, "Error")
	self:NetworkVar("Float", 5, "NextFire")
end

function SWEP:Think()
	if (SERVER) then
		local chargeTime = self.Owner._press_time and CurTime() - self.Owner._press_time or 0

		if (chargeTime + self:GetCharge() >= self.MaxCharge) then
			self:SetCharge(self.MaxCharge)
			self:SetCharged(true)
			self:SetCharging(false)
			self.Owner._press_time = nil
		end

		if (self.Owner._press_time) then
			local ch = CurTime() - self.Owner._press_time + self:GetCharge()

			self:SetCharge(ch)
		end

		local fire = self.nextFire - CurTime()
		if (fire <= 0) then
			fire = 0
		end
		self:SetNextFire(math.Round(fire))
	end
end

function SWEP:Initialize()
	if (SERVER) then
		self.nextFire = self.fireOffset
	end
end

function SWEP:DoError()
	self:SetError(true)

	timer.Create("swep:"..self.Owner:SteamID(), .09, 7, function()
		self:SetError(not self:GetError())
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		local tr = self.Owner:GetEyeTrace()

		if (self.nextFire and CurTime() < self.nextFire) then
			self:DoError()

			return
		end
		if (not self:GetCharged()) then self:DoError() return end

		local tr = self.Owner:GetEyeTrace()
		if (tr.Hit and tr.Entity and tr.Entity:GetClass() == "prop_ragdoll") then
		
			self.nextFire = CurTime() + self.fireOffset
			self:SetNextFire(self.nextFire)

			local fail = self.Owner.medic_fail_rate or self.FailRate
			local dis = self.Owner:GetPos():DistToSqr(tr.HitPos) <= self.FireDistance * self.FireDistance
			local success = math.random(0, 100) / 100 >= fail

			if (tr.Entity:GetClass() == "prop_ragdoll") then

				if (dis and success) then
					if (tr.Entity.player) then
						tr.Entity.player:Spawn()
						tr.Entity.player:SetPos(tr.Entity.player.death_pos)
					end

					tr.Entity:Remove()

					self.Owner:addMoney(self.Money)
					self.Owner:FWChatPrint("You have been paid $"..self.Money.." for reviving someone!")

					self:SetCharge(0)
					self:SetCharged(false)

					self:EmitSound(Sound("ambient/energy/spark5.wav"))

				elseif (not dis) then
					self.Owner:FWChatPrintError("You are too far away!")
				elseif (not success) then
					self.Owner:FWChatPrintError("The revive failed, try again!")
				end

			elseif (tr.Entity:GetClass() == "player") then

				if (dis and success) then
					tr.Entity:TakeDamage(self.Damage, self.Owner, self)
					self:EmitSound(Sound("ambient/energy/spark5.wav"))
				end

			end

			self:DoError()
		end
	end
end


if (CLIENT) then
	local height = 300
	function SWEP:DrawHUD()
		draw.RoundedBox(0, 0, (ScrH() / 2) - height / 2, 30, height, Color(0, 0, 0))

		local progress = self:GetCharge()

		--credit goes to Spai for this
		local perc = (progress / self.MaxCharge) * 90
		local barHeight = (progress / self.MaxCharge) * height
		local barColor = Color((100 - perc) * 2.5, perc * 2.5, 0)

		local blink = barColor
		if (self:GetError()) then
			blink = Color(255, 0, 0)
		end

		local offset = (ScrH() / 2) + (height / 2)
		draw.RoundedBox(0, 0, offset - barHeight, 30, barHeight, blink)

		local offset = (ScrH() / 2) - (height / 2) - 35
		local t = "Next fire in "..(self:GetNextFire() or 0).. " seconds"
		draw.SimpleText(t, fw.fonts.default:atSize(30), 5, offset, Color(0, 0, 0))
	end

else

	fw.hook.Add("KeyPress", "DetectChargeStart", function(ply, key)
		if (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "fw_defib" and key == IN_ATTACK2) then
			ply._press_time = CurTime()
			ply:GetActiveWeapon():SetCharging(true)
		end
	end)

	fw.hook.Add("KeyRelease", "DetectChargeEnd", function(ply, key)
		if (IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "fw_defib" and key == IN_ATTACK2 and ply._press_time) then
			local timeCharged = CurTime() - ply._press_time
			local wep = ply:GetActiveWeapon()

			wep:SetCharging(false)
			
			if (wep:GetCharge() + timeCharged >= wep.MaxCharge) then
				wep:SetCharged(true)
			else
				wep:SetCharge(wep:GetCharge() + timeCharged)
			end
			
			ply._press_time = nil
			wep:SetCharging(false)
		end
	end)

	fw.hook.Add("PlayerDeath", "SetupDefibStuff", function(ply)
		ply.death_pos = ply:GetPos()
		local ragdoll = ents.Create("prop_ragdoll")
	    ragdoll:SetPos(ply:GetPos())
	    ragdoll:SetModel(ply:GetModel())
	    ragdoll:Spawn()
	    ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON )

	    ply.ragdoll_ent = ragdoll

	    ragdoll.player = ply

	    if (ply:GetRagdollEntity()) then
	    	ply:GetRagdollEntity():Remove()
	    end
	end)

	fw.hook.Add("PlayerSpawn", "RemoveRagDoll", function(ply)
		if (IsValid(ply.ragdoll_ent)) then
			ply.ragdoll_ent:Remove()
		end
	end)
end