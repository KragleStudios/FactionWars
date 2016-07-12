if SERVER then AddCSLuaFile() end -- you must add yourself as a CSLua file if you want your module to get loaded on the client

local hook 			= {}
local table_remove 	= table.remove
local debug_info 	= debug.getinfo
local isstring 			= isstring
local isfunction = isfunction
local ipairs 		= ipairs
local IsValid 		= IsValid

local overrides     = _G.___fwhook_overrides or {} _G.___fwhook_overrides = overrides -- the gamemode functions that we have overriden so far
local hooks 		= {}
local mappings 		= {}

hook.GetTable = function()
	return table.Copy(mappings)
end

hook.Call = function(name, ...) 
	if hooks[name] ~= nil then
		for k, v in ipairs(hooks[name]) do
			local a, b, c, d = v(...)
			if a ~= nil then
				return a, b, c, d
			end
		end
	end
	if fw[name] then
		return fw[name](fw, ...)
	end
end local hook_Call = hook.Call


hook.Remove = function(name, id)
	local collection = hooks[name]
	if collection ~= nil then
		local func = mappings[name][id]
		if func ~= nil then
			for k,v in ipairs(collection) do
				if func == v then
					table_remove(collection, k)
					break 
				end
			end
		end
		mappings[name][id] = nil
	end
end

local hook_Remove = hook.Remove
hook.Add = function(name, id, func)
	if not overrides[name] then
		local gmTable = (GM or GAMEMODE)
		if gmTable[name] then
			local old = gmTable[name]
			gmTable[name] = function(self, ...)
				local a, b, c, d = fw.hook.Call(name, ...)
				if a ~= nil then return a, b, c, d end
				return old(...)
			end
		else
			gmTable[name] = function(self, ...)
				return fw.hook.Call(name, ...)
			end
		end
		overrides[name] = gmTable[name]
	end

	if isfunction(id) then
		func = id
		id = debug_info(func).short_src
	end
	hook_Remove(name, id) -- properly simulate hook overwrite behavior

	if not isstring(id) then
		local orig = func
		func = function(...)
			if IsValid(id) then
				return orig(id, ...)
			else
				hook_Remove(name, id)
			end
		end
	end

	local collection = hooks[name]
	
	if collection == nil then
		collection = {}
		hooks[name] = collection
		mappings[name] = {}
	end

	local mapping = mappings[name]

	collection[#collection+1] = func
	mapping[id] = func
end


return hook