if SERVER then
	hook.Add('Think','AAF',function()
		include('aaf.lua')
		hook.Remove('Think','AAF')
	end)
end
if CLIENT then
	AddCSLuaFile('aaf_client.lua')
end