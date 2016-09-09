ENT.Type = "anim"
ENT.Base = "durgz_base"
ENT.PrintName = "LSD"
ENT.Nicknames = {"LSD", "acid"}
ENT.OverdosePhrase = {"used too much", "tripped out on"}
ENT.Author = "cheesylard (inspired by ninjers)"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Information	 = " lol high scientists" 

ENT.TRANSITION_TIME = 6

--function for high visuals

if(CLIENT)then

	killicon.Add("durgz_lsd","killicons/durgz_lsd_killicon",Color( 255, 80, 0, 255 ))

	local TRANSITION_TIME = ENT.TRANSITION_TIME; --transition effect from sober to high, high to sober, in seconds how long it will take etc.
	local HIGH_INTENSITY = 0.77; --1 is max, 0 is nothing at all
	
	
	local function DoLSD()
		if(!DURGZ_LOST_VIRGINITY)then return; end
		--self:SetNetworkedFloat( "SprintSpeed"
		local pl = LocalPlayer();
		
		
		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		//tab[ "$pp_colour_brightness" ] = 0
		//tab[ "$pp_colour_contrast" ] = 1
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0
		
		
		if( pl:GetNetworkedFloat("durgz_lsd_high_start") && pl:GetNetworkedFloat("durgz_lsd_high_end") > CurTime() )then
		
			if( pl:GetNetworkedFloat("durgz_lsd_high_start") + TRANSITION_TIME > CurTime() )then
			
				local s = pl:GetNetworkedFloat("durgz_lsd_high_start");
				local e = s + TRANSITION_TIME;
				local c = CurTime();
				local pf = (c-s) / (e-s);
				
				tab[ "$pp_colour_colour" ] =   1 + pf*3
				tab[ "$pp_colour_brightness" ] = -pf*0.19
				tab[ "$pp_colour_contrast" ] = 1 + pf*5.31
				DrawBloom(0.65, (pf^2)*0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
				
			elseif( pl:GetNetworkedFloat("durgz_lsd_high_end") - TRANSITION_TIME < CurTime() )then
			
				local e = pl:GetNetworkedFloat("durgz_lsd_high_end");
				local s = e - TRANSITION_TIME;
				local c = CurTime();
				local pf = 1 - (c-s) / (e-s);
				
				tab[ "$pp_colour_colour" ] =   1 + pf*3
				tab[ "$pp_colour_brightness" ] = -pf*0.19
				tab[ "$pp_colour_contrast" ] = 1 + pf*5.31
				DrawBloom(0.65, (pf^2)*0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
				
			else
				
				
				tab[ "$pp_colour_colour" ] =   1 + 3
				tab[ "$pp_colour_brightness" ] = -0.19
				tab[ "$pp_colour_contrast" ] = 1 + 5.31
				DrawBloom(0.65, 0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
				
			end
			
			
		end
	end
	
	
	/*local function DoMsgLSD()
		local pl = LocalPlayer();
		
		
		
		if( pl:GetNetworkedFloat("durgz_lsd_high_start") && pl:GetNetworkedFloat("durgz_lsd_high_end") > CurTime() )then
		
			local say = "main"
			
			if( pl:GetNetworkedFloat("durgz_lsd_high_start") + TRANSITION_TIME > CurTime() )then
			
				say = "trans"
				
			elseif( pl:GetNetworkedFloat("durgz_lsd_high_end") - TRANSITION_TIME < CurTime() )then
			
				say = "trans"
				
			end
			draw.DrawText(say, "ScoreboardHead", ScrW() / 2+1 , ScrH()*0.6+1, Color(255,255,255,255),TEXT_ALIGN_CENTER) 
			draw.DrawText(say, "ScoreboardHead", ScrW() / 2-1 , ScrH()*0.6-1, Color(255,255,255,255),TEXT_ALIGN_CENTER) 
			draw.DrawText(say, "ScoreboardHead", ScrW() / 2-1 , ScrH()*0.6+1, Color(255,255,255,255),TEXT_ALIGN_CENTER) 
			draw.DrawText(say, "ScoreboardHead", ScrW() / 2+1 , ScrH()*0.6-1, Color(255,255,255,255),TEXT_ALIGN_CENTER) 
			draw.DrawText(say, "ScoreboardHead", ScrW() / 2 , ScrH()*0.6, Color(255,9,9,255),TEXT_ALIGN_CENTER) 
		end
	end
	hook.Add("HUDPaint", "durgz_lsd_msg", DoMsgLSD)*/
	
	hook.Add("RenderScreenspaceEffects", "durgz_lsd_high", DoLSD)
end