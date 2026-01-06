fx_version 'cerulean'
game 'gta5'

author 'GODZ Team'
description 'GODZ Support System (Tickets & AI)'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'config.lua',
    'server.lua'
}
