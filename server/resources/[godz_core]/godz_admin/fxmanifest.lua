fx_version 'cerulean'
game 'gta5'

author 'Unity Core'
description 'GODZ Ecosystem - Admin Tablet'
version '2.0.0'

ui_page 'nui/index.html'

client_scripts {
    'client.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}
