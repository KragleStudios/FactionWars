if SERVER then
	AddCSLuaFile()
end

fw.zone = {}
 
-- external dependencies
require 'ra'

-- require modules
fw.dep(SHARED, 'data')

-- define constants
fw.zone.zoneDataDir = fw.config.dataDir .. (SERVER and '/zones_sv/' or '/zones_cl/')
file.CreateDir(fw.zone.zoneDataDir)

-- include files
fw.include_sh 'zones_sh.lua'
fw.include_cl 'zones_cl.lua'
fw.include_sv 'zones_sv.lua'