if !SERVER then return end

local id = 1
local resc = {}
resc.__index = resc

resc.Resources = {}

function resc.register(class, printname, colour, icon16)
	if resc.exists(class) then return resc.Resources[class] end
	local resource = setmetatable({ ["class"] = class, ["printname"] = (printname || class), ["id"] = id, ["colour"] = colour, ["icon"] = icon16}, resc)
	resc.Resources[class] = resource
	id = id + 1
	return resource
end

function resc.getResources()
	return resc.Resources
end

function resc.getResource(class)
	if resc.Exists(class) then
		return resc.Resources[class]
	end
	return false
end

function resc.exists(class)
	if resc.Resources[class] then
		return true
	end
	return false
end

function resc:getClass()
	return self.class
end

function resc:getID()
	return self.id
end

function resc:getName()
	return self.printname
end

function resc:getColour()
	return self.colour
end

function resc:getIcon()
	return self.icon
end

return resc