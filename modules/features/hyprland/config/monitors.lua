-- Dell U3419W ultrawide: right monitor (3440x1440)
hl.monitor({ output = "DP-1", mode = "3440x1440@59.970", position = "2560x0", scale = "1" })

-- LG ULTRAGEAR+ 1440p: left monitor
hl.monitor({ output = "DP-3", mode = "2560x1440@143.99", position = "0x0", scale = "1" })

-- Fallback for any other monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

-- Disable eDP-1 when external monitors are present, enable it when alone
local function updateLaptopDisplay()
	local monitors = hl.get_monitors()
	local hasExternal = false
	for _, m in ipairs(monitors) do
		if m.name == "DP-1" or m.name == "DP-3" then
			hasExternal = true
			break
		end
	end

	if hasExternal then
		hl.monitor({ output = "eDP-1", disabled = true })
	else
		hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "1" })
	end
end

updateLaptopDisplay()

hl.on("monitor.added", function() updateLaptopDisplay() end)
hl.on("monitor.removed", function() updateLaptopDisplay() end)
