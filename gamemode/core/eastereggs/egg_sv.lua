fw.hook.Add("DoPlayerDeath", "DoScream", function(ply, att, dmg)
  local rand = math.random(1, 100)
  if (rand <= 5 and dmg:IsDamageType(DMG_BLAST)) then
    ply:EmitSound('sounds/scream.mp3')
  end
end)

fw.hook.Add("PlayerSay", "EasterEggs", function(ply, msg)
  if msg:find("do a barrel roll") then
    net.Start("fw.BarrelRoll")
    net.Send(ply)
  end
  if msg:find("poop") then
    local prop = ents.Create("prop_physics")
    prop:SetModel("models/Gibs/HGIBS_spine.mdl")
    prop:SetPos(ply:GetPos() + Vector(0,0,32))
    prop:Spawn()
    prop:SetColor(80, 45, 0, 255)
    prop:SetMaterial("models/props_pipes/pipeset_metal")
    ply:EmitSound("ambient/levels/canals/swamp_bird2.wav", 50, 80)

    timer.Simple(30, function() if prop:IsValid() then prop:Remove() end end)
  end

  return ""
end)
