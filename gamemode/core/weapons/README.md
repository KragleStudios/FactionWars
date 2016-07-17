# Weapons
Adding a new weapon is very similar to printers.

`fw.weapons.createGun(string Name, table Config, string Entity)`

# Config table
`WorldModel`: (string) The worldmodel of the gun.

`ViewModel`: (string) The viewmodel of the gun.

`ViewModelFlip`: (bool) Should the viewmodel be flipped?

`HoldType`: (string) Gun hold pose

`ReloadSound`: (string) Sound that plays when you reload the gun

`Slot`: (int) The slot the weapon is in. Please use `fw.weapons.SLOT_*` for these.

`Scoped`: (bool) Does the gun use a scope?

`Primary`: (table) Weapon info.

# Primary Table
`Ammo`: (string) Ammo type

`ClipSize`: (int) Max ammo in clip

`DefaultClip`: (int) How much extra ammo the gun spawns with

`Automatic`: (bool) Automatic/Semi-Auto

`Damage`: (int) Amount of damage each bullet does

`RPM`: (int) Amount of bullets shot per miniute

`Sound`: (string) Sound the gun makes when it shoots

`BaseSpread`: (float) Base amount of spread the gun has

`BaseRecoil`: (float) Base amount of recoil the gun has. Recoil is increased by this value on every shot.

`MaxRecoil`: (float) The maximum amount of recoil a gun can reach.

`Shotgun`: (bool) Is the gun a shotgun?

`Bulllets`: (int) If shotgun is set to true, this is the amount of bullets the gun wil fire.

# Example:
```lua
fw.weapons.createGun("AK-47", {
	WorldModel = "models/weapons/w_rif_ak47.mdl",
	ViewModel = "models/weapons/v_rif_ak47.mdl",
	ViewModelFlip = true,
	HoldType = "AR2",
	ReloadSound = Sound("Weapon_AK47.Reload"),
	Slot = fw.weapons.SLOT_RIFLE,
	Primary = {
		Ammo = "AR2",
		ClipSize = 30,
		DefaultClip = 60,
		Automatic = true,
		Damage = 27,
		RPM = 600,
		Sound = Sound("Weapon_AK47.Single"),
		BaseSpread = 0.02,
		BaseRecoil = 0.0075,
		MaxRecoil = 0.15,
	},
}, "fw_gun_ak47")
```
