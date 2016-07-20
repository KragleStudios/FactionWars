AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

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