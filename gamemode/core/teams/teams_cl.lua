function fw.team.setPreferredModel(jobId, model)
	net.Start('fw.team.preferredModel')
		net.WriteString(fw.team.list[jobId].stringID)
		net.WriteString(model)
	net.SendToServer()
end
