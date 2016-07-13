if !SERVER then return end

fw.dep(SHARED, "hook")

local resource = {}
resource.manager  = fw.include_sv "sv_resourcemanager.lua"

-- Resources are registered here
resource.manager.register("res_water", "Water", Color(41, 128, 185), "icon16/wrench.png")
resource.manager.register("res_power", "AU", Color(241, 196, 15), "icon16/lightning.png")
resource.manager.register("res_oil", "Oil", Color(16,16,16), "icon16/bomb.png")

return resource