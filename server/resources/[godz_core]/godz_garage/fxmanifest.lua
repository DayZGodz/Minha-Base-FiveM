fx_version 'cerulean'
game 'gta5'

author 'GODZ'
description 'GODZ Garage System with AI Integration'
version '1.0.0'

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

dependencies {
    'vrp',
    'oxmysql'
}
