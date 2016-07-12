if !SERVER then return end

local id = 1
local resc = {}
resc.__index = resc

resc.Resources = {}

function resc.register(class, printname, colour, icon16)
	if resc.Exists(class) then return resc.Resources[class] end
	local resource = setmetatable({ ["class"] = class, ["printname"] = (printname || class), ["id"] = id, ["colour"] = colour, ["icon"] = icon16}, resc)
	resc.Resources[class] = resource
	id = id + 1
	return resource
end

function resc.GetResources()
	return resc.Resources
end

function resc.GetResource(class)
	if resc.Exists(class) then
		return resc.Resources[class]
	end
	return false
end

function resc.Exists(class)
	if resc.Resources[class] then
		return true
	end
	return false
end

function resc:GetClass()
	return self.class
end

function resc:GetID()
	return self.id
end

function resc:GetName()
	return self.printname
end

function resc:GetColour()
	return self.colour
end

function resc:GetIcon()
	return self.icon
end

return resc