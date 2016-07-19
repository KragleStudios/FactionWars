include("shared.lua")

fw.dep("hook")

function ENT:Draw()
	self:DrawModel()
end

fw.hook.Add("RenderScreenspaceEffects", "MethEffects", function()
	if (IsValid(LocalPlayer())) then
		if (LocalPlayer():GetFWData().methTime and CurTime() <= LocalPlayer():GetFWData().methTime) then
			DrawSharpen(1.2, 1.2)
		end
	end
end)