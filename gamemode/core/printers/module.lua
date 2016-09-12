if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, "hook")

fw.printers = fw.printers or {}

fw.include_sh "printers_sh.lua"

concommand.Add("fw_reloadprinters", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then pl:ChatPrint("insufficient privliages") return end
	fw.hook.GetTable().Initialize.LoadPrinters()
end)