if SERVER then

	util.AddNetworkString('fw.hud.pushNotification')
	function fw.hud.pushNotification(players, title, message, color)
		if not color then color = color_white end

		net.Start('fw.hud.pushNotification')
			net.WriteUInt(color.r, 8)
			net.WriteUInt(color.g, 8)
			net.WriteUInt(color.b, 8)
			net.WriteString(title)
			net.WriteString(message)
		net.Send(players or player.GetAll())

	end

else

	net.Receive('fw.hud.pushNotification', function()
		local color = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
		fw.hud.pushNotification(net.ReadString(), net.ReadString(), color)
	end)

end
