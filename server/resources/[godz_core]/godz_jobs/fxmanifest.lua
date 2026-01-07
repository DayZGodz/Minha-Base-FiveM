fx_version 'cerulean'
game 'gta5'

author 'GODZ'
description 'Sistema de Empregos Modular GODZ'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client.lua',
    'jobs/*.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua',
    'jobs/*.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/assets/*'
}
