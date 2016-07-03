require 'ra'

fw = {
	--debug = true
}

-- gamemode variables
(GM or GAMEMODE).Name = "Faction Wars"
(GM or GAMEMODE).Author = "thelastpenguin, Ott, Seris, Kalamitous, Mikey Howell, Nookyava, Spai"
(GM or GAMEMODE).Email = ""
(GM or GAMEMODE).Website = "https://github.com/GMFactionWars"

-- utils
local resolvePath = function(fn)
	local function resolvePathHelper(stackdepth, path)
		if file.Exists(path, 'LUA') then return path end
		local info = debug.getinfo(stackdepth, "S").short_src
		info:sub(info:find('/') + 1) -- strip off the first / 
		info = ra.path.normalize(ra.path.getFolder(info) .. '/' .. path)
		if file.Exists(info, 'LUA') then return info end
		return path
	end
	return function(...)
		fn(resolvePathHelper(3, ...))
	end
end
fw.include_sv = resolvePath(include or function() end)
fw.include_cl = resolvePath(AddCSLuaFile or include) 
fw.include_sh = resolvePath(function(path)
	if SERVER then AddCSLuaFile(path) end
	return include(path)
end)


-- module loader
print "-----------------------"
print " factionwars v0.1.0 Alpha "
print "-----------------------"

fw.module_srcs = {}
fw.loaded_modules = {}
fw.module_search_paths = {
	(GM or GAMEMODE).FolderName .. '/gamemode/core',
	(GM or GAMEMODE).FolderName .. '/gamemode/plugins',
	'fw_plugins',
}

-- fw.dep with printing
-- fw.dep(cond:bool, name:string)
-- @param cond:bool - if true then it loads, if false then it doesnt i.e. fw.dep(SERVER, ...)
-- @param name:string - the name of the module to load i.e. hooks
-- @ret nothing
function fw.dep(cond, name)
	if fw.loaded_modules[name] then return fw[name] end
	fw.loaded_modules[name] = true

	if not cond then return end

	local oldprint = _G.print
	if fw.debug then
		_G.print = function(...)
			oldprint("    ", ...)
		end
	else
		_G.print = function() end
	end
	timer.Create('restore-print-function', 0, 1, function()
		_G.print = oldprint
	end)
	
	Msg(" - [module] " .. name)
	fw[name] = include(fw.module_srcs[name])
	Msg(" " .. string.rep('.', 30 - name:len()) .. " ")
	MsgC(Color(0, 255, 0), "ok\n")
	_G.print = oldprint

	return fw[name]
end

SHARED = SERVER or CLIENT -- true

print "Search Paths: "
for k,v in ipairs(fw.module_search_paths) do
	print(" - " .. v)
end

print "Modules: "
for _, searchPath in ipairs(fw.module_search_paths) do
	local _, directories = file.Find(searchPath.. '/*', 'LUA')
	for k, dir in ipairs(directories) do
		fw.module_srcs[dir] = searchPath .. '/' .. dir .. '/module.lua'
	end

	-- call dep on every module
	for k,v in pairs(fw.module_srcs) do
		if not fw[k] then
			fw.dep(SHARED, k)
		end
	end
end



-- fw.dep without printing
function fw.dep(name)
	if fw.loaded_modules[name] then return fw[name] end
	fw.loaded_modules[name] = true
	fw[name] = include(fw.module_srcs[name])
	return fw[name]
end
