return
fx_version 'adamant'

game 'gta5'

-- Resource Metadata
author 'EddiesLife247'
description 'Full ANPR System | Ped Alerts, ANPR Cameras, Prop Detection'
version '1.1.1'
lua54 'yes' -- This ensures the asset is compatible with Lua 5.4


version '0.1.0'


client_scripts {
    'client.lua',
}
server_scripts {
    'server.lua',
}

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

exports {
    'CheckAndDispatchBOLO', -- ? Add this line to export the function
    'IsPlateBOLO', -- Optional: Export other useful functions
    'GetLastANPRDetection',
    'GetLastPedAlert'
}

escrow_ignore {
    'config.lua',              -- Ignoring the main configuration file
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}


dependency 'qb-core'
dependency 'ox_lib'