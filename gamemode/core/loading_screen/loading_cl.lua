
-- TODO: Rewrite loading screen using stylish
-- TODO: Move loading screen away from timers


surface.CreateFont("SubTextLoading", {font = "Roboto", size = 24, weight = 300})
local sayings, tbl = {
	"Loading something to do with NetDoc",
	"Oh no NetDoc Desync.. let me fix that",
	"I hear there's a script that already has that ;)",
	"'None of this would be possible without our sponsors, scriptfodder, eugecus and facepunch' - Kragle Studios",
	"Anyone can do it, but it is all about how you edit it, that is what not everyone can do correctly."
}, {}
local logo = Material("kragle/logo.png")
local w,h,mX,mY,cOffset = ScrW(), ScrH(), ScrW() * .5, ScrH() * .5, 100
local pMeta = FindMetaTable("Player")
local Frame

function pMeta:openLoadingScreen()
	if IsValid(Frame) then return end

	Frame = vgui.Create("DPanel")
	Frame:SetSize(w, h)
	Frame.Paint = function(pnl,w,h)
		surface.SetDrawColor(32,32,32)
		surface.DrawRect(0,0,w,h)

		draw.NoTexture()
		surface.SetDrawColor(Color(2,152,219))
		for i=1, 4 do
			--draw.Arc(mX,mY - (cOffset), 50 + ((i - 1) * 15), 10, ( math.abs(math.sin(CurTime() * i * (i * .02))) * 360)  , ( math.abs(math.sin(CurTime() * i * (i * .02)) * 360) ) + 90, 5, Color(2,152,219) )
			ra.surface.DrawArc(mX,mY - (cOffset), 50 + ((i - 1) * 15),  50 + ((i - 1) * 15) + 10, ( math.abs(math.sin(CurTime() * i * (i * .02))) * 360)  , ( math.abs(math.sin(CurTime() * i * (i * .02)) * 360) ) + 90, 15)
		end

		surface.SetFont("SubTextLoading")
		for i=1, 5 do
			surface.SetTextColor(230,230,230, 255 - (i * 45))
			surface.SetTextPos(mX - surface.GetTextSize(tbl[i] or "") * .5, h * .52 + (i * 30))
				surface.DrawText(tbl[i] or "")
		end

		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(logo)
			surface.DrawTexturedRect(w * .5 - 165, 50, 300,130)
	end

	local Percent = vgui.Create("DLabel", Frame)
	Percent:SetFont("DermaLarge")
	Percent:SetTextColor(Color(255,255,255))
	Percent:SetText("1%")
	Percent:SetPos(w * .5 - surface.GetTextSize(Percent:GetText()) * .6, h * .5 - cOffset - 15)
	Percent:SizeToContents()

	
	timer.Create("Loading_Percent",.1,100,function() -- please dont judge me for using timers, it was only supposed to be for testing
		if not IsValid(Percent) then return end
		Percent:SetText(100 - timer.RepsLeft("Loading_Percent") .. "%")
		Percent:SetPos(w * .5 - surface.GetTextSize(Percent:GetText()) * .6, h * .5 - cOffset - 15)
		Percent:SizeToContents()

		if timer.RepsLeft("Loading_Percent") == 0 then
			self:closeLoadingScreen(true)
			self._isLoading = false
		end
	end)

	timer.Create("Loading_Sayings", 1.8, 5, function() -- look above
		table.insert(tbl, 1, sayings[#sayings - timer.RepsLeft("Loading_Sayings")])
	end)

	self._isLoading = true
end

function pMeta:isLoading() 
	return self._isLoading
end

function pMeta:closeLoadingScreen(shouldFade)
	if IsValid(Frame) then 
		if shouldFade then
			Frame:AlphaTo(0,2, 1, function()
				Frame:Remove()
			end)
		else
			Frame:Remove()
		end
	end
end

sty.WaitForLocalPlayer(function()
	if not LocalPlayer():isLoading() then
		timer.Simple(4, function() LocalPlayer():openLoadingScreen() end) -- This is called slightly before we can actually see the screen (e.g. sending client info)
	end
end)

concommand.Add("fw_open_loading", function(ply)
	ply:openLoadingScreen()
end)

concommand.Add("fw_close_loading", function(ply)
	if IsValid(Frame) then
		Frame:Remove()
	end
end)
