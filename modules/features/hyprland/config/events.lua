local appList = {
	"wpaperd -d",
	"gotify-desktop",
	"quickshell",
	"nm-applet --indicator",
	"wl-paste --watch cliphist store",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
