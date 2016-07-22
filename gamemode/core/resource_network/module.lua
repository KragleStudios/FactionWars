if not SERVER then end

local network = {}

network = fw.include_sv "sv_networkmanager.lua"
network.network = fw.include_sv "sv_network.lua"

network.RegisterEntityNode("fw_generator") -- Register this entity as a node is the networks


return network