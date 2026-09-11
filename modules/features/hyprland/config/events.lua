local appList = {
	"wpaperd -d",
	"gotify-desktop",
	"quickshell",
	"nm-applet --indicator",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(appList) do
		hl.exec_cmd(command)
	end
end)
