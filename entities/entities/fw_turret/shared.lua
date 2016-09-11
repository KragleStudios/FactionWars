ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Turret"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Faction Wars"

ENT.Resources = true

ENT.radius = 300
ENT.clip = 100
ENT.damage = 5
ENT.show_radius = true

--default offset for shots to be fired
ENT.fire_offset = 8 --ms
--how much should ammo cost(full clip, part clips are calculated)
ENT.ammo_cost = 1000
--how much should the entity have for default health
ENT.health = 100

--create new upgrades here.
--NOTE: you can add as many as you want :D
ENT.upgrades = {
	[1] = {
		fire_offset = 5,
		clipsize = 200,
		damage   = 6,
		radius = 400,
		cost = 5000,
		ammmo_cost = 1000,
		health = 200
	},
	[2] = {
		fire_offset = 2,
		model = "models/combine_turrets/floor_turret.mdl",
		cost = 5000,
		ammmo_cost = 1000,
		health = 300
	},
	[3] = {
		clipsize = 300,
		damage = 8,
		cost = 5000,
		ammmo_cost = 1000,
		health = 400
	},
	[4] = {
		fire_offset = 1.5,
		clipsize = 350,
		can_control = true,
		cost = 5000,
		ammmo_cost = 1000,
		health = 500
	}
}

--setup our data
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "UpgradeStatus")
	self:NetworkVar("Entity", 1, "Owner")
	self:NetworkVar("String", 2, "Remaining")
	self:NetworkVar("Bool", 3, "Targeting")
	self:NetworkVar("Int", 4, "TargetingDistance")
	self:NetworkVar("Bool", 5, "Status") --true for on, off for off
	self:NetworkVar("Angle", 6, "DefaultAngle")
	self:NetworkVar("Int", 7, "MaxClip")
	self:NetworkVar("Bool", 8, "CanControl")

	self:NetworkVar("Int", 9, "Damage")
	self:NetworkVar("Int", 10, "Radius")
	self:NetworkVar("Int", 11, "FireOffset")

		self:NetworkVar("Bool", 12, "MenuOpen")
	self:NetworkVar("Int", 13, "AmmoCost")
	self:NetworkVar("Int", 14, "THealth")
	self:NetworkVar("Int", 15, "TMaxHealth")
	self:NetworkVar("Int", 16, "Cooldown")
end
