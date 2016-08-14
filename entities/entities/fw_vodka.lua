ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Vodka"
ENT.Category 		= "Faction Wars"
ENT.Author			= "sanny"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if (SERVER) then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_junk/glassbottle01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:PhysWake()

		self:SetUseType(SIMPLE_USE)
	end

	function ENT:Use(event, ply)
		if IsValid(ply) then
			ply:GetFWData().vodkaTime = (ply:GetFWData().vodkaTime or CurTime()) + 60
			self:Remove()
		end
	end

	fw.hook.Add("EntityTakeDamage", "VodkaEffects", function(entity, dmgInfo)
		-- awesome
		if (entity:IsPlayer() and entity:GetFWData().vodkaTime and CurTime() <= entity:GetFWData().vodkaTime) then
			dmgInfo:ScaleDamage(0.9)
		end
	end)

else
	function ENT:Draw()
		self:DrawModel()
	end

	fw.hook.Add("RenderScreenspaceEffects", "VodkaEffects", function()
		if (IsValid(LocalPlayer())) then
			if (LocalPlayer():GetFWData().vodkaTime and CurTime() <= LocalPlayer():GetFWData().vodkaTime) then
				DrawSobel(0.5)
			end
		end
	end)
end