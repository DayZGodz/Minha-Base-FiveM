fx_version 'cerulean'
game 'gta5'

author 'GODZ Team'
description 'GODZ Factions - Gestão Avançada de Grupos'
version '1.0.0'

shared_scripts {
    '@vrp/lib/utils.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}
