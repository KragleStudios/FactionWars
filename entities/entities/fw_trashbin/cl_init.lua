
include("shared.lua")

function ENT:Initialize()
end

function ENT:Think()

end

function ENT:OnRemove( )
	
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	self.CanSpawn = self:GetNWFloat("CanSpawn",SysTime())
end
 
hook.Add("HUDPaint","TrashIndicator",function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if !IsValid(ent) then return end 
	if ent:GetClass()!="ent_trashbin" then return end
	if ent.CanSpawn>=SysTime() then return end
	surface.SetFont("default")
	local text = "E to search"
	local tx,ty = surface.GetTextSize(text)
	surface.SetTextColor(Color(255,255,255))
	surface.SetTextPos(ScrW()/2-tx/2,ScrH()/2-ty/2-30)
	surface.DrawText(text)

end)