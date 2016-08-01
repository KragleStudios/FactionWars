require 'ra'
DeriveGamemode("sandbox")

local function load()

fw = {
	debug = true
}


-- gamemode variables
(GM or GAMEMODE).Name = "Faction Wars"
(GM or GAMEMODE).CondensedName = "FW"
(GM or GAMEMODE).Author = "thelastpenguin, Mikey Howell, Spai, crazyscouter, meharryp, sanny"
(GM or GAMEMODE).Email = ""
(GM or GAMEMODE).Website = "https://github.com/GMFactionWars"
(GM or GAMEMODE).Version = "0.1.0 Alpha"

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
fw.include_sv = resolvePath(ra.include_sv)
fw.include_cl = resolvePath(ra.include_cl) 
fw.include_sh = resolvePath(ra.include_sh)

fw.print = ra.print 


-- module loader
print "--------------------------"
print " factionwars v0.1.0 Alpha "
print "--------------------------"

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


-- fw.dep without printing for things that get loaded later
function fw.dep(name)
	if fw.loaded_modules[name] then return fw[name] end
	fw.loaded_modules[name] = true
	fw[name] = include(fw.module_srcs[name])
	return fw[name]
end


-- todo crawler
if fw.debug then
	print "--------------------------"
	print " factionwars todo list    "
	print "--------------------------"
	local function todoFinder(directory)
		local files, directories = file.Find(directory .. '/*', 'LUA')
		for k,v in ipairs(files) do
			local data = file.Read(directory .. '/' .. v, 'LUA')
			if (not data) then continue end
			for k, line in ipairs(string.Explode('\n', data)) do
				if line and line:find('--') and line:find('TODO') then
					MsgC(color_white, directory .. '/' .. v .. ':' .. k)
					local start = string.find(line, 'TODO') + 4
					MsgN(string.sub(line, start))
				end
			end
		end

		for k,v in ipairs(directories) do
			todoFinder(directory .. '/' .. v)
		end
	end

	for k,v in ipairs(fw.module_search_paths) do
		todoFinder(v)
	end
end

if SERVER then
	RunConsoleCommand("sbox_godmode", "0")
end

end load() -- local function load()



-- load default hooks for base gamemode compatability
fw.include_sh 'hooks_sh.lua'




-- allow for reloading 
concommand.Add('fw_reload', function(pl)
	if IsValid(pl) and not pl:IsSuperAdmin() then pl:ChatPrint('insufficient privliages') return end
	load()

	fw.hook.Call('Initialize')
	for k, pl in ipairs(player.GetAll()) do 
		fw.hook.Call('PlayerInitialSpawn', pl)
		fw.hook.Call('PlayerSpawn', pl)
	end 
	
end)

concommand.Add("fw_reloadmap", function(pl)
	if IsValid(pl) and not pl:IsSuperAdmin() then pl:ChatPrint('insufficient privliages') return end
	fw.print("Reloading map...")
	RunConsoleCommand("changelevel", game.GetMap())
end )
