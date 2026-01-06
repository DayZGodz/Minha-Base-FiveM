fx_version 'cerulean'
game 'gta5'

author 'GODZ Ecosystem'
description 'GODZ Jobs Pro - Sistema de Carreiras e XP'
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
    'nui/script.js',
    'nui/style.css'
}

dependencies {
    'godz_core',
    'godz_target',
    'godz_bank',
    'godz_interface'
}
