util.AddNetworkString("FW_ShowTeam")

fw.hook.Add("ShowTeam", "DisplayHelpMenu", function(ply)
	net.Start("FW_ShowHelp")
	net.Send(ply)
end)