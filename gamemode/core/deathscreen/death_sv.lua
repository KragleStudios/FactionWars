util.AddNetworkString("playerDeath")

hook.Add("PlayerDeath", "Death", function (victim, inflictor, attacker)
        local bool = (victim == attacker) or attacker:IsWorld() or (attacker:GetClass() == "prop_physics") or false

        net.Start("playerDeath")
                net.WriteBool(bool)
	        net.WriteEntity(attacker)
	net.Send(victim)
end)
