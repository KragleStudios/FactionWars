ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Meth"
ENT.Category 		= "Faction Wars"
ENT.Author			= "sanny"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (SERVER) then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_lab/huladoll.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()

		self:SetUseType(SIMPLE_USE)
	end

	function ENT:Use(event, ply)
		if IsValid(ply) then
			local timerName = "MethEffects"..tostring(ply:EntIndex())

			ply:SetRunSpeed(800)

			if (!ply:GetFWData().meth) then
				ply:GetFWData().meth = true
			end

			if (timer.Exists(timerName)) then
				timer.Adjust(timerName, timer.TimeLeft(timerName) + 20, 1, function()
					if IsValid(ply) then
						ply:SetRunSpeed(320)
						ply:GetFWData().meth = nil
					end
				end)
			else
				timer.Create(timerName, 20, 1, function()
					if IsValid(ply) then
						ply:SetRunSpeed(320)
						ply:GetFWData().meth = nil
					end
				end)
			end

			self:Remove()
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end

	fw.hook.Add("RenderScreenspaceEffects", "MethEffects", function()
		if (IsValid(LocalPlayer())) then
			if (LocalPlayer():GetFWData().meth) then
				DrawSharpen(1.2, 1.2)
			end
		end
	end)
end
