fw.hook.Add("PostDrawOpaqueRenderables", "drawOverhead", function()
	for k, v in pairs(player.GetAll()) do
		local boneIndex = v:LookupBone("ValveBiped.Bip01_Head1")
		local bonePos = v:GetBonePosition(boneIndex)
		local pos = bonePos + Vector(0, 0, 20) 
		local eye = LocalPlayer():EyeAngles()
		local ang = Angle(0, eye.y - 90, 90)

		local font = fw.fonts.default_compact_shadow:atSize(50)
		local color = v:getFaction() and fw.team.factions[v:getFaction()].color or Color(255, 255, 255)

		cam.Start3D2D(pos, ang, 0.1)
			draw.SimpleTextOutlined(v:Nick(), font, 0, 0, color, TEXT_ALIGN_CENTER, 0, 0.5, color_black)
		cam.End3D2D()
	end
end)
