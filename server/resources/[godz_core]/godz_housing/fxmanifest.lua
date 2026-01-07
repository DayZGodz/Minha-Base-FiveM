fx_version 'cerulean'
game 'gta5'

author 'GODZ Dev Team'
description 'GODZ Housing - Sistema de Propriedades com Shells e Decoração'
version '1.0.0'

shared_scripts {
    '@vrp/lib/utils.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@vrp/lib/utils.lua',
    'server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

dependencies {
    'vrp',
    'oxmysql',
    'godz_target',
    'godz_bank'
}
