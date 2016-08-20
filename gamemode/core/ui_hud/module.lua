if SERVER then AddCSLuaFile() end

require "sty"

fw.hud = {}

fw.dep(CLIENT, "ui")
fw.dep(CLIENT, "fonts")
fw.dep(CLIENT, "hook")
fw.dep(CLIENT, "teams")
fw.dep(CLIENT, "zones")

fw.include_cl "hud_cl.lua"
--fw.include_cl "entity_info_cl.lua"
fw.include_cl "hud_overhead_cl.lua"
fw.include_cl "notification_feed_cl.lua"
fw.include_sh "notification_feed_sh.lua"
fw.include_sv "notification_def_sv.lua"
