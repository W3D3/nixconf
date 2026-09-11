-- Built-in laptop display: disabled when external monitors are connected
hl.monitor({ output = "eDP-1", disabled = true })

-- Dell U3419W ultrawide: right monitor (3440x1440)
hl.monitor({ output = "DP-1", mode = "3440x1440@59.970", position = "2560x0", scale = "1" })

-- LG ULTRAGEAR+ 1440p: left monitor
hl.monitor({ output = "DP-3", mode = "2560x1440@143.99", position = "0x0", scale = "1" })

-- Fallback for any other monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
