AddCSLuaFile("shared.lua")
include("shared.lua")

local MAX_SCALE = 8; -- the higher this number the more the damage is multiplied (making this -1 is funny)

ENT.MODEL = "models/Gibs/HGIBS_rib.mdl";
ENT.MASS = 15;


ENT.LASTINGEFFECT = 20; --how long the high lasts in seconds

--called when you use it (after it sets the high visual values and removes itself already)
function ENT:High(activator,caller)

	activator.durgz_pcp_originalhealth = activator:Health();
	activator.durgz_pcp_lasthealth = activator:Health();
end
function ENT:AfterHigh(activator,caller)
	if( activator:Health() <=10 )then
		activator.DURGZ_MOD_DEATH = "durgz_pcp";
		activator.DURGZ_MOD_OVERRIDE = activator:Nick().." "..self.OverdosePhrase[math.random(1, #self.OverdosePhrase)].." "..self.Nicknames[math.random(1, #self.Nicknames)].." and died.";
		activator:Kill()
	return
	end
	local sayings = {
		"HELLO. MY NAME IS JARED AND I LIKE FOOTBALL.",
		"MY ARMS ARE LIKE FUCKING CANNONS",
		"FOOTBALLLL",
		"REEEED! MENOS TRES"
	}
	self:Say(activator, ""..sayings[math.random(1,#sayings)])
end


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( self.Classname )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end

local function ScaleDamage( ent, inflictor, attacker, amount, dmginfo )
	if(!server_settings.Bool( "durgz_roleplay", 0 ))then //if we're not in roleplay mode, then continue on.
		//when the PCP high person is attacking.
		local pl = attacker;
		if( pl:IsPlayer() && pl:GetNetworkedFloat("durgz_pcp_high_start") && pl:GetNetworkedFloat("durgz_pcp_high_end") > CurTime() )then
			local scale;
			if( pl:GetNetworkedFloat("durgz_pcp_high_start") + 3 > CurTime() )then
				scale = 1 + MAX_SCALE*(CurTime() - pl:GetNetworkedFloat("durgz_pcp_high_start"))/3


			elseif( pl:GetNetworkedFloat("durgz_pcp_high_end") - 3 < CurTime() )then
				scale = 1 + MAX_SCALE*(pl:GetNetworkedFloat("durgz_pcp_high_end") - CurTime())/3
			else
				scale = 1 + MAX_SCALE;
			end
			dmginfo:ScaleDamage(scale);
			dmginfo:SetDamageForce(dmginfo:GetDamageForce()*scale*10);

		end
		//when the PCP high person is being attacked.
		pl = ent;
		if( pl:IsPlayer() && pl:GetNetworkedFloat("durgz_pcp_high_start") && pl:GetNetworkedFloat("durgz_pcp_high_end") > CurTime() )then
			local scale;
			if( pl:GetNetworkedFloat("durgz_pcp_high_start") + 3 > CurTime() )then
				scale = 1 + MAX_SCALE*(CurTime() - pl:GetNetworkedFloat("durgz_pcp_high_start"))/3/2


			elseif( pl:GetNetworkedFloat("durgz_pcp_high_end") - 3 < CurTime() )then
				scale = 1 + MAX_SCALE*(pl:GetNetworkedFloat("durgz_pcp_high_end") - CurTime())/3/2
			else
				scale = 1 + MAX_SCALE/2;
			end
			dmginfo:ScaleDamage(scale);
			dmginfo:SetDamageForce(dmginfo:GetDamageForce()*scale*10);

		end
	end
end
hook.Add("EntityTakeDamage", "PCPScale", ScaleDamage);

local lastThink = 0;

local function RandomizeHealth()
	if(CurTime() - lastThink < 0.2)then return; end
	lastThink = CurTime();
	local health;
	for _, pl in pairs(player.GetAll())do
		if !(pl:GetNetworkedFloat("durgz_pcp_high_start") && pl:GetNetworkedFloat("durgz_pcp_high_end") > CurTime() && pl.durgz_pcp_originalhealth)then return; end
		health = pl:Health();
		if(pl.durgz_pcp_lasthealth != health)then
			pl.durgz_pcp_originalhealth = pl.durgz_pcp_originalhealth - pl.durgz_pcp_lasthealth + health;
		end
		local randhealth = math.random(pl.durgz_pcp_originalhealth/2, pl.durgz_pcp_originalhealth);
		pl:SetHealth(randhealth);
		pl.durgz_pcp_lasthealth = pl:Health();
	end
end
hook.Add("Think", "PCPRandomizeHealth", RandomizeHealth);
