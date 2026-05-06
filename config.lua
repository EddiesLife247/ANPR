-- config.lua

Config = {}

-- BOLO System Settings
Config.BoloExpiryTime = 1200 -- BOLO expiry time in seconds (10 minutes)
Config.AllowedJobs = {"police", "roadspolicing", "cid", "response", "firearms", "staff"} -- Allowed jobs for BOLO commands
Config.BoloDistance = 60
Config.DebugMode = false
Config.Cooldown = 15000 -- time in ms for cooldown, currently set to 15 seconds before can restart.

-- Blip and Alert Toggles
Config.GlobalBlipToggle = false -- Enable or disable all ANPR blips globally
Config.EnablePedAlerts = true -- Enable or disable ped-based alerts
Config.EnableAnprAlerts = true -- Enable or disable ANPR-based alerts
Config.EnableLGModsSpeedAnpr = true
Config.ModelHash = 1868764591
Config.PersistantBolos = true
Config.ExportsEnabled = true
Config.CommandsEnabled = true
Config.EnableDispatch = true

Config.SQLPersistantBolo = "SELECT vehicles FROM tk_mdt_incidents WHERE JSON_CONTAINS(vehicles, '{\"hasBOLO\": true}')"
    Config.SQLPersistantWarrant = [[
    SELECT pv.*
    FROM player_vehicles pv
    JOIN tk_mdt_incidents ti
    ON JSON_CONTAINS(ti.criminals, JSON_OBJECT('identifier', pv.citizenid, 'hasWarrant', true))
]];


-- ANPR System Settings
Config.AnprCameras = { -- ANPR camera configurations
    {
        coords = vec3(2.52, -973.89, 29.55), -- Camera location
        radius = 10.0, -- Detection radius (in game units)
        cooldown = 20000, -- Cooldown for detections (in milliseconds)
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1937.62, 2450.34, 54.06), -- Camera location
        radius = 30.0, -- Detection radius (in game units)
        cooldown = 20000, -- Cooldown for detections (in milliseconds)
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },

    {
        coords = vec3(2546.05, 4193.2, 40.35), -- Camera location
        radius = 10.0, -- Detection radius (in game units)
        cooldown = 20000, -- Cooldown for detections (in milliseconds)
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(250.0, -1000.0, 29.0), -- Another camera location
        radius = 10.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-1876.28, -473.62, 24.45), -- Another camera location
        radius = 10.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-1379.99, -390.44, 36.42), -- Another camera location
        radius = 10.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2364.64, -277.07, 14.07), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2936.91, 92.94, 13.31), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2999.41, 1474.41, 27.43), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2364.64, -277.07, 14.07), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2615.48, 2910.86, 16.4), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-1780.56, 4737.94, 56.73), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-446.05, 5917.59, 32.4), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1064.15, 6484.67, 20.75), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2514.74, 5492.39, 44.37), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2821.14, 3467.06, 54.82), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1978.62, 2543.29, 54.38), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1635.62, 1166.4, 83.75), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1302.85, 597.0, 79.78), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2344.74, 1085.64, 80.15), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2353.47, -335.9, 85.07), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1600.7, -969.47, 61.02), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2542.34, 1678.59, 27.79), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1778.04, 3366.05, 39.77), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1853.52, 3662.92, 33.85), -- Another camera location
        radius = 20.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(563.47, 3507.01, 33.91), -- Another camera location
        radius = 30.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-78.87, 2823.28, 52.93), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-1182.56, 2606.68, 14.79), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-2132.34, 2307.01, 36.77), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(628.76, 2698.01, 40.79), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(2576.42, 4241.97, 41.42), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(1696.35, 4709.32, 42.27), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(291.31, 163.38, 103.97), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-126.96, -222.75, 44.55), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-659.15, -298.74, 35.23), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-659.15, -298.74, 35.23), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-636.63, -2295.6, 5.78), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
    {
        coords = vec3(-945.4, -1808.91, 19.55), -- Another camera location
        radius = 40.0, -- Larger radius
        cooldown = 30000, -- Custom cooldown
        blip = {
            enabled = true, -- Toggle for this camera's blip
            sprite = 184,
            color = 3,
            scale = 1.0,
            name = "ANPR Camera"
        }
    },
}

