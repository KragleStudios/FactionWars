if SERVER then AddCSLuaFile() end

require "sty"

voiceVis = {}

fw.dep(CLIENT, "ui")
fw.dep(CLIENT, "fonts")
fw.dep(CLIENT, "hook")
fw.dep(CLIENT, "teams")

fw.include_cl "voice_chat_cl.lua"
