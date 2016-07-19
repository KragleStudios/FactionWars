include("shared.lua")

fw.dep("hook")

function ENT:Draw()
	self:DrawModel()
end

fw.hook.Add("RenderScreenspaceEffects", "BeerEffects", function()
	if (IsValid(LocalPlayer())) then
		if (LocalPlayer():GetFWData().drunkTime and CurTime() <= LocalPlayer():GetFWData().drunkTime) then
			DrawSobel(0.5)
		end
	end
end)