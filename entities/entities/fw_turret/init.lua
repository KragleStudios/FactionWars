AddCSLuaFile("shared.lua")
AddCSLuaFile('3d2dvgui.lua')
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("fw.updateTurretStatus")
util.AddNetworkString("fw.upgradeTurret")
util.AddNetworkString("fw.toggleMenu")
util.AddNetworkString("fw.buyAmmo")

--setup initial conditions :v
--wow that's a lot of network variables
function ENT:Initialize()
	self:SetModel("models/combine_turrets/ground_turret.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(self:GetPos() + Vector(0, 0, 20))
	self:DropToFloor()

	local ang = self:GetAngles()
	self:SetAngles(Angle(0, ang.y, 0))
	--self:SetTrigger(true)

	self:SetUseType(SIMPLE_USE)

	self:SetUpgradeStatus(0)
	self:SetOwner(self)
	self:SetRemaining(self.clip)
	self:SetTargeting(false)
	self:SetTargetingDistance(0)
	self:SetStatus(false)
	self:SetMaxClip(self.clip)
	self:SetCanControl(false)
	self:SetMenuOpen(true)

	self:SetTHealth(self.health)
	self:SetTMaxHealth(self.health)

	self:SetCooldown(0)
	
	self:SetDamage(self.damage)
	self:SetRadius(self.radius)
	self:SetFireOffset(self.fire_offset)
	self:SetAmmoCost(self.ammo_cost)

	self.origin_ang = self:GetAngles()
	self:SetDefaultAngle(self:GetAngles())

	self.last_fire = CurTime()

	self.shoot_positions = {
		Vector(0, 0, 0)
	}
	self.angle_offset = 180
end

--opens the menu on entity use
function ENT:Use(act, caller)
	if (not IsValid(caller) or self:GetMenuOpen()) then return end
	
	self:SetMenuOpen(not self:GetMenuOpen())
end

--handles upgrades
function ENT:Upgrade(tbl)
	self:SetUpgradeStatus(tbl.upgrade_id) --1 to whatever
	self:SetRemaining(tbl.clipsize or self:GetMaxClip()) --if no clip upgrade just reset it
	self:SetMaxClip(tbl.clipsize or self:GetMaxClip())
	self:SetDamage(tbl.damage or self:GetDamage())
	self:SetRadius(tbl.radius or self:GetRadius())
	self:SetFireOffset(tbl.fire_offset or self:GetFireOffset())
	self:SetModel(tbl.model or self:GetModel())
	self:SetAmmoCost(tbl.ammo_cost or self:GetAmmoCost())
	self:SetTHealth(tbl.health or self:GetTMaxHealth())
	self:SetTMaxHealth(tbl.health or self:GetTMaxHealth())

	self:DropToFloor()

	self.shoot_positions = tbl.shoot_positions or self.shoot_positions --for multiple turret holes!
	self:SetCanControl(tbl.can_control or false)
	self:SetCooldown(0)
end

--handles entity health
function ENT:OnTakeDamage(dmg)
	local damage = dmg:GetDamage()
	if (self:GetTHealth() - damage < 0) then
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("Explosion", effect)

		self:Remove()
		return
	end

	self:SetTHealth(self:GetTHealth() - damage)
end

--determines whether an entity is abled to be targeted
function ENT:ShouldTarget(target)
	if (not target:IsPlayer()) then return false end
	if (not target:inFaction()) then return false end
	if (IsValid(self:GetNWEntity("owner")) and IsValid(target) and target:getFaction() == self:GetNWEntity("owner"):getFaction()) then return false end
	if (self:GetNWEntity("owner") == target) then return false end

	return true
end

--finds the closest targetable entity
function ENT:FindNearest()
	local near = nil
	local range = self:GetRadius() * self:GetRadius()

	local entlist = ents.GetAll()
	if (#entlist == 0) then return end

	for _,ent in pairs(entlist) do
		if (not ent:IsPlayer() and not self:ShouldTarget(ent)) then continue end

		local dis = self:GetPos():DistToSqr(ent:GetPos())
		if (dis <= range) then
			near = ent
			range = dis
		end
	end

	return near, range
end

--resets the targeting state
function ENT:ResetData()
	self:SetTargeting(false)
	self:SetTargetingDistance(0)
end

--determines if the weapon has the ability to shoot
function ENT:ShouldFire()
	local bullets = self:GetRemaining()

	if (not self.last_fire) then return true end --hasn't fire yet
	if (bullets - 1 < 0) then return false end

	return true
end

--fires bullets
function ENT:FireThisShit()
	self:SetRemaining(self:GetRemaining() - #self.shoot_positions)-- - 1)
	self.last_fire = CurTime()

	for k,v in pairs(self.shoot_positions) do
		local targ_pos = self.target:GetPos() + Vector(0, 0, 50)

		local tr = util.TraceLine({
				start = v,
				endpos = targ_pos
			})

		if (not tr.Hit or not tr.Entity) then continue end
		if (tr.Entity != self.target) then continue end

		local fire_tbl = {
			Damage = self:GetDamage(),
			Distance = self:GetRadius(),
			Dir = targ_pos,
			Src = v
		}

		self:FireBullets(fire_tbl)
	end
end


--handles entity positions and finding / shooting of targets
local ang = 0
local floater_angle = Angle(0, 0, 0)
local shouldChange = true
local offset = 1
function ENT:Think()
	if (not self:GetStatus()) then 
		self:ResetData()
		return 
	end

	if (IsValid(self)) then
		--blah blah fancy rotating gun code :D
		if (not self:GetTargeting() and self:GetStatus()) then
			if (shouldChange) then
				ang = ang - offset
				if (ang == -180) then
					shouldChange = false
				end
			elseif (not shouldChange) then
				ang = ang + offset
				if (ang == 180) then
					shouldChange = true
				end
			end

			self:SetAngles(self.origin_ang + Angle(0, ang, 0))
		end
	end

	--make sure we find an entity
	local nearest, distance = self:FindNearest()
	if (not nearest) then self:ResetData() return end
	if (not IsValid(nearest)) then 
		self:ResetData()
		return
	end
	if (not self:ShouldFire()) then --this is an error state function
		self:ResetData()
		self:SetStatus(false)
		return
	end
	if (not self:ShouldTarget(nearest)) then 
		self:ResetData()
		return 
	end

	self.target = nearest
	self:SetTargeting(true)
	self:PointAtEntity(nearest)
	self.targeting_angle = self:GetAngles()

	self:SetAngles(Angle(0, self.targeting_angle.y, 0))

	self:SetTargetingDistance(math.sqrt(distance))

	if (CurTime() < self.last_fire + self:GetFireOffset()) then
		self:SetCooldown(CurTime() - self.last_fire + 1)

		return 
	end

	self:FireThisShit()
end

--toggles the turret on or off
net.Receive("fw.updateTurretStatus", function(l, caller)
	local ent = net.ReadEntity()
	local bool = net.ReadBool()

	if (not IsValid(ent) or not ent:ShouldFire()) then return end

	local dis = caller:GetPos():DistToSqr(ent:GetPos())
	if (dis > 75 * 75) then 
		return
	end

	ent:SetStatus(bool)
end)

--handles the player trying to upgrade the turret
net.Receive("fw.upgradeTurret", function(l, caller)
	local ent = net.ReadEntity()

	if (not IsValid(ent)) then return end

	local dis = caller:GetPos():DistToSqr(ent:GetPos())
	if (dis > 75 * 75) then 
		return
	end
	
	local upgrade_status = ent:GetUpgradeStatus()
	local target_upgrade = ent.upgrades[upgrade_status + 1]
	if (not target_upgrade) then return end

	local mon = caller:getMoney()

	if (mon - target_upgrade.cost < 0) then return end
	caller:addMoney(-target_upgrade.cost)
	
	target_upgrade.upgrade_id = ent:GetUpgradeStatus() + 1

	ent:Upgrade(target_upgrade)
end)

--turns the menu off
net.Receive("fw.toggleMenu", function(l, caller)
	local ent = net.ReadEntity()

	if (not IsValid(ent)) then return end

	local dis = caller:GetPos():DistToSqr(ent:GetPos())
	if (dis > 75 * 75) then 
		return
	end

	ent:SetMenuOpen(not ent:GetMenuOpen())
end)

--handles the player trying to buy ammo
net.Receive("fw.buyAmmo", function(l, caller)
	local ent = net.ReadEntity()

	if (not IsValid(ent)) then return end

	local dis = caller:GetPos():DistToSqr(ent:GetPos())
	if (dis > 75 * 75) then 
		return
	end

	--only charge for the ammo needed
	local ammo_cost = (ent:GetRemaining() / ent:GetMaxClip()) * ent:GetAmmoCost()
	ammo_cost = math.Round(ent:GetAmmoCost() - ammo_cost)

	if (caller:getMoney() - ammo_cost < 0) then return end
	if (tonumber(ent:GetRemaining()) != tonumber(ent:GetMaxClip())) then 
		caller:addMoney(-ammo_cost)
		ent:SetRemaining(ent:GetMaxClip())
	end
end)