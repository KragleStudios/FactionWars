print "loading kragle core!"

fw.hook.Add('PlayerSay', function(pl)
	pl:Kill()
end)