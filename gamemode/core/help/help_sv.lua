util.AddNetworkString("FW_ShowHelp")

fw.hook.Add("ShowHelp", "DisplayHelpMenu", function(ply)
	net.Start("FW_ShowHelp")
	net.Send(ply)
end)