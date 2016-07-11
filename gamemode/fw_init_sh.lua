require 'ra'

local function load()

fw = {
	--debug = true
}

-- gamemode variables
(GM or GAMEMODE).Name = "Faction Wars"
(GM or GAMEMODE).Author = "thelastpenguin, Ott, Seris, Kalamitous, Mikey Howell, Nookyava, Spai, crazyscouter"
(GM or GAMEMODE).Email = ""
(GM or GAMEMODE).Website = "https://github.com/GMFactionWars"

-- utils
local resolvePath = function(fn)
	local function resolvePathHelper(stackdepth, path)
		if file.Exists(path, 'LUA') then return path end
		local info = debug.getinfo(stackdepth, "S").short_src
		info = info:sub(info:find('/') + 1) -- strip off the first / 
		info = ra.path.normalize(ra.path.getFolder(info) .. '/' .. path)
		if file.Exists(info, 'LUA') then return info end
		return path
	end
	return function(...)
		return fn(resolvePathHelper(3, ...))
	end
end
fw.include_sv = resolvePath(SERVER and include or function() end)
fw.include_cl = resolvePath(SERVER and AddCSLuaFile or include) 
fw.include_sh = resolvePath(function(path)
	if SERVER then AddCSLuaFile(path) end
	return include(path)
end)

function fw.print(...)
	print('[FW]', ...)
end


-- module loader
print "-----------------------"
print " factionwars v0.1.0 Alpha "
print "-----------------------"

fw.module_srcs = {}
fw.loaded_modules = {}
fw.module_search_paths = {
	(GM or GAMEMODE).FolderName .. '/gamemode/libraries',
	(GM or GAMEMODE).FolderName .. '/gamemode/core',
	(GM or GAMEMODE).FolderName .. '/gamemode/plugins',
	'fw_plugins',
}

-- fw.dep with printing
-- fw.dep(cond:bool, name:string)
-- @param cond:bool - if true then it loads, if false then it doesnt i.e. fw.dep(SERVER, ...)
-- @param name:string - the name of the module to load i.e. hooks
-- @ret module:table - the module's method table
function fw.dep(cond, name)
	if fw.loaded_modules[name] then return fw[name] end

	if not cond then return end

	if not fw.module_srcs[name] then error("no such module \'" .. name .. "\'") end

	Msg(" - [module] " .. name)
	Msg(" " .. string.rep('.', 30 - name:len()) .. " ")
	MsgC(Color(255, 155, 0), "loading\n")

	local ret = include(fw.module_srcs[name])
	if ret then fw[name] = ret end

	Msg(" - [module] " .. name)
	Msg(" " .. string.rep('.', 30 - name:len()) .. " ")
	MsgC(Color(0, 255, 0), "OK\n")

	fw.loaded_modules[name] = true

	return fw[name]
end

SHARED = true

print "Search Paths: "
for k,v in ipairs(fw.module_search_paths) do
	print(" - " .. v)
end

print "Modules: "

fw.include_sv '_config_sv.lua'
fw.include_sh '_config_sh.lua'
fw.include_cl '_config_cl.lua'

for _, searchPath in ipairs(fw.module_search_paths) do
	local _, directories = file.Find(searchPath.. '/*', 'LUA')
	for k, dir in ipairs(directories) do
		fw.module_srcs[dir] = searchPath .. '/' .. dir .. '/module.lua'
	end
end

-- call dep on every module
for k,v in pairs(fw.module_srcs) do
	if not fw[k] then
		fw.dep(SHARED, k)
	end
end


-- fw.dep without printing
function fw.dep(name)
	if fw.loaded_modules[name] then return fw[name] end
	fw.loaded_modules[name] = true
	fw[name] = include(fw.module_srcs[name])
	return fw[name]
end


end load() -- local function load()

-- allow for reloading 
concommand.Add('fw_reload', function(pl)
	if not pl:IsSuperAdmin() then return end
	load()
end)
