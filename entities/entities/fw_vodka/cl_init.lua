include("shared.lua")

fw.dep("hook")

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