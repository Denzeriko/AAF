local function OnPopulateToolPanel(panel)
	panel:AddControl("Button", {
		Label = "Enable AAF",
		Command = "aaf_enable",
	})
	panel:AddControl("Button", {
		Label = "Toggle AddFile Addons",
		Command = "aaf_addon",
	})
	panel:AddControl("Button", {
		Label = "Toggle AddFile Resources",
		Command = "aaf_other",
	})
	panel:AddControl("Button", {
		Label = "Toggle Console Massages",
		Command = "aaf_massages",
	})
	panel:AddControl("Button", {
		Label = "Toggle Auto Update",
		Command = "aaf_update",
	})
end

function OnPopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "AAFSettings", "AutoAddFile", "", "", OnPopulateToolPanel, {SwitchConVar = 'aaf_enable'})
end

hook.Add("PopulateToolMenu", "AAF", OnPopulateToolMenu)