if SERVER then
	util.AddNetworkString("fw.BarrelRoll")

	fw.hook.Add("PlayerSay", "EasterEggs", function(ply, msg)
		if msg:find("do a barrel roll") then
			net.Start("fw.BarrelRoll")
			net.Send(ply)
		end
	end)
else
	net.Receive("fw.BarrelRoll", function()
		local rollstate = 0
		fw.hook.Add("CalcView", "BarrelRoll", function(ply, pos, ang, fov)
			rollstate = rollstate + FrameTime() * 200
			local view = {}

			view.origin = pos
			view.angles = ang + Angle(0, 0, rollstate)
			view.fov = fov
			view.drawviewer = false

			if rollstate >= 360 then
				fw.hook.Remove("CalcView", "BarrelRoll")
			end

			return view
		end)
	end)
end
